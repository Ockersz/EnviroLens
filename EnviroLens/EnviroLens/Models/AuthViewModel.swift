import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var lastSignedInEmail: String?

    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    func signInWithUsername(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                guard let document = snapshot?.documents.first,
                      let email = document.data()["email"] as? String else {
                    completion(false, NSError(domain: "Auth", code: 404, userInfo: [NSLocalizedDescriptionKey: "Username not found."]))
                    return
                }
                
                self?.lastSignedInEmail = email // ✅ Save the email
                self?.signIn(email: email, password: password, completion: completion)
            }
    }

    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Sign-in error: \(error.localizedDescription)")
                completion(false, error)
            } else {
                self?.user = result?.user
                completion(true, nil)
            }
        }
    }

    
    // MARK: - Sign Up (Register)
    func signUp(name: String, username: String, email: String, password: String, area: String) {
        // First check if username is already taken
        checkUsernameExists(username: username) { exists in
            if exists {
                print("Username already taken.")
                return
            }
            
            // Create Firebase Auth user
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                if let error = error {
                    print("Sign-up error: \(error.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let userData: [String: Any] = [
                    "name": name,
                    "username": username,
                    "email": email,
                    "area": area,
                    "createdAt": Timestamp(date: Date())
                ]
                
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        print("Error saving user data: \(error.localizedDescription)")
                    } else {
                        print("User successfully signed up and saved.")
                        self?.user = result?.user
                    }
                }
            }
        }
    }
    
    // MARK: - Check Username Availability
    private func checkUsernameExists(username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking username: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let count = snapshot?.documents.count, count > 0 {
                    completion(true) // exists
                } else {
                    completion(false) // available
                }
            }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
        }
    }
}
