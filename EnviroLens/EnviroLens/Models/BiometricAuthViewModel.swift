//
//  BiometricAuthViewModel.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-11.
//


import LocalAuthentication
import SwiftUI

class BiometricAuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authError: String?
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Face ID"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                    } else {
                        self.authError = authenticationError?.localizedDescription
                    }
                }
            }
        } else {
            // Biometric authentication not available
            DispatchQueue.main.async {
                self.authError = error?.localizedDescription ?? "Biometric authentication not available."
            }
        }
    }
}


extension String: @retroactive Identifiable {
    public var id: String { self }
}
