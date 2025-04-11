import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @State private var name = "Shahein Ockersz"
    @State private var username = "shahein"
    @State private var email = "shaheinockersz1234@gmail.com"
    @State private var password = "Ockersz@$5"
    @State private var confirmPassword = "Ockersz@$5"
    @State private var selectedArea = "Colombo" //"Select Area"
    @State private var acceptTerms = true //false
    @State private var isShowingAreaDialog = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) var dismiss
    
    let areas = ["Colombo", "Galle", "Kandy", "Jaffna", "Matara"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image("RecycleBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top, 10)
                
                Text("Sign up")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Name", text: $name)
                    if !FormValidator.isValidName(name) {
                        Text("Name cannot be empty.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Username", text: $username)
                    if !FormValidator.isValidUsername(username) {
                        Text("Username must be 3–15 characters, alphanumeric or underscore.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    } else if !FormValidator.isUsernameAllowed(username) {
                        Text("This username is reserved. Please choose another.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    customTextField("Email", text: $email, keyboardType: .emailAddress)
                    if !FormValidator.isValidEmail(email) {
                        Text("Please enter a valid email address.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    secureCustomField("Password", text: $password)
                    if !FormValidator.isStrongPassword(password) {
                        Text("Password must be 8+ chars, include upper/lowercase, number & special char.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    secureCustomField("Confirm Password", text: $confirmPassword)
                    if !FormValidator.passwordsMatch(password, confirmPassword) {
                        Text("Passwords do not match.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                Button(action: {
                    isShowingAreaDialog = true
                }) {
                    HStack {
                        Text(selectedArea)
                            .foregroundColor(selectedArea == "Select Area" ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(height: 50)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .confirmationDialog("Select Your Area", isPresented: $isShowingAreaDialog) {
                    ForEach(areas, id: \.self) { area in
                        Button(area) {
                            selectedArea = area
                        }
                    }
                }
                
                if selectedArea == "Select Area" {
                    Text("Please select an area.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                HStack(alignment: .top) {
                    Button(action: {
                        acceptTerms.toggle()
                    }) {
                        Image(systemName: acceptTerms ? "checkmark.square" : "square")
                            .foregroundColor(Color("PrBtnCol"))
                    }
                    
                    Text("I accept the ") +
                    Text("Terms").underline().foregroundColor(.blue) +
                    Text(" and ") +
                    Text("Privacy Policy").underline().foregroundColor(.blue)
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                if !acceptTerms {
                    Text("You must accept the terms and privacy policy.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: registerUser) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 50)
                    } else {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("PrBtnCol"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .disabled(!formIsValid())
                
                HStack {
                    Text("Already a member?")
                        .foregroundColor(.secondary)
                    Button("Login") {
                        withAnimation {
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                }
                .font(.footnote)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
    }
    
    func customTextField(_ placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
    }
    
    func secureCustomField(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .padding()
            .frame(height: 50)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
            .padding(.horizontal)
    }
    
    func formIsValid() -> Bool {
        FormValidator.isValidName(name) &&
        FormValidator.isValidUsername(username) &&
        FormValidator.isUsernameAllowed(username) &&
        FormValidator.isValidEmail(email) &&
        FormValidator.isStrongPassword(password) &&
        FormValidator.passwordsMatch(password, confirmPassword) &&
        selectedArea != "Select Area" &&
        acceptTerms
    }
    
    func registerUser() {
        print("registering user")
        isLoading = true
        errorMessage = ""
        
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("🔥 Firebase Error: \(error)")
                    print("🔥 Description: \(error.localizedDescription)")
                    self.errorMessage = "Failed to register: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                
                if snapshot?.documents.count ?? 0 > 0 {
                    errorMessage = "Username already taken."
                    isLoading = false
                    return
                }
                
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("🔥 Firebase Error: \(error)")
                        print("🔥 Description: \(error.localizedDescription)")
                        errorMessage = "Failed to register: \(error.localizedDescription)"
                        isLoading = false
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let userData: [String: Any] = [
                        "name": name,
                        "username": username,
                        "email": email,
                        "area": selectedArea,
                        "createdAt": Timestamp()
                    ]
                    
                    db.collection("users").document(uid).setData(userData) { error in
                        isLoading = false
                        if let error = error {
                            print("🔥 Firebase Error: \(error)")
                            print("🔥 Description: \(error.localizedDescription)")
                            errorMessage = "Failed to save user data: \(error.localizedDescription)"
                        } else {
                            dismiss()
                        }
                    }
                }
            }
    }
}

#Preview {
    RegisterView()
}
