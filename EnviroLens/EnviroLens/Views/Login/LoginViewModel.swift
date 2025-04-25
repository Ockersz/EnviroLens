//
//  LoginViewModel.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-18.
//


import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var attemptedLogin = false
    @Published var navigateToRegister = false
    @Published var navigateToHome = false

    let authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }

    var isFormValid: Bool {
        FormValidator.isValidUsername(username) && !password.isEmpty
    }

    func handleLogin() {
        attemptedLogin = true
        guard isFormValid else { return }

        isLoading = true
        errorMessage = ""

        authViewModel.signInWithUsername(username: username, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    _ = KeychainManager.save(email: self?.authViewModel.lastSignedInEmail ?? "", password: self?.password ?? "")
                    self?.navigateToHome = true
                }
            }
        }
    }
}
