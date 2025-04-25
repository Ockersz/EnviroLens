//
//  FormValidator.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-11.
//

import Foundation


struct FormValidator {
    static func isValidName(_ name: String) -> Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    static func isValidUsername(_ username: String) -> Bool {
        let regex = "^[a-zA-Z0-9_]{3,15}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: username)
    }

    static func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    static func passwordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    static func isStrongPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    static func isUsernameAllowed(_ username: String) -> Bool {
        let reserved = ["admin", "support", "help", "root"]
        return !reserved.contains(username.lowercased())
    }
    
    static func isNotBlank(_ input: String) -> Bool {
        return !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}
