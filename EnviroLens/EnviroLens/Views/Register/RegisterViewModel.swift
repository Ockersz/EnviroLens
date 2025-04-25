//
//  RegisterViewModel.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-18.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class RegisterViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var selectedArea: String = "Select Area"
    @Published var acceptTerms: Bool = false
    
    @Published var isShowingAreaDialog: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    @Published var attemptedRegister: Bool = false
    @Published var registrationSuccess: Bool = false
    
    let areas = ["Colombo", "Galle", "Kandy", "Jaffna", "Matara"]

    var isFormValid: Bool {
        FormValidator.isValidName(name) &&
        FormValidator.isValidUsername(username) &&
        FormValidator.isUsernameAllowed(username) &&
        FormValidator.isValidEmail(email) &&
        FormValidator.isStrongPassword(password) &&
        FormValidator.passwordsMatch(password, confirmPassword) &&
        selectedArea != "Select Area" &&
        acceptTerms
    }
    
    func registerUser(completion: @escaping () -> Void) {
        attemptedRegister = true
        guard isFormValid else { return } // checks everytime is the form valid first if only continues.

        isLoading = true
        errorMessage = ""

        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: username)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to register: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                if snapshot?.documents.count ?? 0 > 0 { //username should be unique.
                    self.errorMessage = "Username already taken."
                    self.isLoading = false
                    return
                }
                
                Auth.auth().createUser(withEmail: self.email, password: self.password) { result, error in
                    if let error = error {
                        self.errorMessage = "Failed to register: \(error.localizedDescription)"
                        self.isLoading = false
                        return
                    }
                    
                    guard let uid = result?.user.uid else {
                        self.errorMessage = "User ID could not be retrieved."
                        self.isLoading = false
                        return
                    }
                    
                    let userData: [String: Any] = [
                        "name": self.name,
                        "username": self.username,
                        "email": self.email,
                        "area": self.selectedArea,
                        "createdAt": Timestamp()
                    ]
                    
                    db.collection("users").document(uid).setData(userData) { error in
                        self.isLoading = false
                        if let error = error {
                            self.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                        } else {
                            self.registrationSuccess = true
                            completion()
                        }
                    }
                }
            }
    }
}
