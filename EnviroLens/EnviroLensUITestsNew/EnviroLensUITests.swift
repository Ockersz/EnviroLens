//
//  EnviroLensUITests.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-15.
//

import XCTest

final class EnviroLensUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // 1. Check if login fields are visible
    func testLoginFieldsExist() throws {
        XCTAssertTrue(app.textFields["usernameField"].exists)
        XCTAssertTrue(app.secureTextFields["passwordField"].exists)
        XCTAssertTrue(app.buttons["loginButton"].exists)
    }
    
    // 2. Valid login should go to MainTabView
    func testValidLoginNavigatesToHome() throws {
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        usernameField.tap()
        usernameField.typeText("shahein")
        
        passwordField.tap()
        passwordField.typeText("Ockersz@$5")
        
        loginButton.tap()
        
        let home = app.otherElements["MainTabView"]
        XCTAssertTrue(home.waitForExistence(timeout: 5), "Expected to navigate to home screen")
    }
    
    // 3. Invalid login should show error
    func testInvalidLoginShowsErrorMessage() throws {
        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]
        let loginButton = app.buttons["loginButton"]
        
        usernameField.tap()
        usernameField.typeText("invalidUser")
        
        passwordField.tap()
        passwordField.typeText("wrongPassword")
        
        loginButton.tap()
        
        let errorText = app.staticTexts["Username not found."]
        XCTAssertTrue(errorText.waitForExistence(timeout: 3), "Expected an error message for invalid credentials")
    }
    
    // 4. Tap login with empty form should show validation errors
    func testEmptyFormShowsValidationMessages() throws {
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        
        let usernameError = app.staticTexts["Please enter a valid username."]
        let passwordError = app.staticTexts["Password cannot be empty."]
        
        XCTAssertTrue(usernameError.waitForExistence(timeout: 2))
        XCTAssertTrue(passwordError.waitForExistence(timeout: 2))
    }
    
    // 5. Navigate to Sign Up/Register screen
    func testNavigationToRegisterScreen() throws {
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.exists)
        
        signUpButton.tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 5), "Expected to navigate to Register screen")
    }
    
    // 6. Face ID login button should exist
    func testFaceIDButtonExists() throws {
        let faceIDButton = app.buttons["biometricLoginButton"]
        XCTAssertTrue(faceIDButton.exists, "Face ID login button should be visible")
    }
    
    // 7. Submit empty form - show all validation messages
    func testRegisterEmptyFormShowsValidationErrors() throws {
        app.buttons["Sign Up"].tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 3))
        
        let registerButton = app.buttons["RegisterButton"]
        XCTAssertTrue(registerButton.exists)
        registerButton.tap()
        
        XCTAssertTrue(app.staticTexts["Name cannot be empty."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Username must be 3–15 characters, alphanumeric or underscore."].exists)
        XCTAssertTrue(app.staticTexts["Please enter a valid email address."].exists)
        XCTAssertTrue(app.staticTexts["Password must be 8+ chars, include upper/lowercase, number & special char."].exists)
        XCTAssertTrue(app.staticTexts["Please select an area."].exists)
        XCTAssertTrue(app.staticTexts["You must accept the terms and privacy policy."].exists)
    }
    
    // 8. Password mismatch error
    func testRegisterPasswordMismatchShowsError() throws {
//        app.buttons["Sign Up"].tap()
//        
//        let registerView = app.otherElements["RegisterView"]
//        XCTAssertTrue(registerView.waitForExistence(timeout: 3))
//        
//        let passwordField = app.secureTextFields["PwdField"]
//        XCTAssertTrue(passwordField.exists)
//        passwordField.press(forDuration: 0.5)
//        sleep(1)
//        passwordField.typeText("StrongP@ss1")
//        
//        let confirmField = app.secureTextFields["ConfField"]
//        XCTAssertTrue(confirmField.exists)
//        confirmField.press(forDuration: 0.5)
//        sleep(1)
//        confirmField.typeText("WrongP@ss1")
//        
//        app.buttons["RegisterButton"].tap()
//        
//        let errorLabel = app.staticTexts["Passwords do not match."]
//        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2))
    }

    
    // 9. Invalid email shows error
    func testRegisterInvalidEmailShowsError() throws {
        app.buttons["Sign Up"].tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 3))
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("invalid-email")
        
        app.buttons["Sign up"].tap()
        
        XCTAssertTrue(app.staticTexts["Please enter a valid email address."].waitForExistence(timeout: 2))
    }
    
    // 10. Weak password shows error
    func testRegisterWeakPasswordShowsError() throws {
        app.buttons["Sign Up"].tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 3))
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("123")
        
        app.buttons["Sign up"].tap()
        
        XCTAssertTrue(app.staticTexts["Password must be 8+ chars, include upper/lowercase, number & special char."].waitForExistence(timeout: 2))
    }
    
    // 11. Area not selected shows error
    func testRegisterUnselectedAreaShowsError() throws {
        app.buttons["Sign Up"].tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 3))
        
        app.buttons["Sign up"].tap()
        
        XCTAssertTrue(app.staticTexts["Please select an area."].waitForExistence(timeout: 2))
    }
    
    // 12. Terms not accepted shows error
    func testRegisterUncheckedTermsShowsError() throws {
        app.buttons["Sign Up"].tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 3))
        
        app.buttons["Sign up"].tap()
        
        XCTAssertTrue(app.staticTexts["You must accept the terms and privacy policy."].waitForExistence(timeout: 2))
    }
}
