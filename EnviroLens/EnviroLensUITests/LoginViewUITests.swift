//
//  LoginViewUITests.swift
//  EnviroLensUITests
//
//  Created by Shahein Ockersz on 2025-04-15.
//

import XCTest

final class LoginViewUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-UITestMode"]
        app.launchEnvironment = ["UITesting": "1"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
    }
    
    func testLoginWithValidCredentials() throws {
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 3))
        usernameField.tap()
        usernameField.typeText("shahein")
        
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 3))
        passwordField.tap()
        passwordField.typeText("Ockersz@$5")
        
        let continueButton = app.buttons["loginButton"]
        XCTAssertTrue(continueButton.exists)
        continueButton.tap()
        
        let homeScreen = app.otherElements["MainTabView"]
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 5), "Should navigate to MainTabView after successful login.")
    }
    
    func testLoginWithInvalidCredentials() throws {
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.exists)
        usernameField.tap()
        usernameField.typeText("invalidUser")
        
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("wrongPassword")
        
        let continueButton = app.buttons["loginButton"]
        XCTAssertTrue(continueButton.exists)
        continueButton.tap()
        
        let errorText = app.staticTexts["Invalid credentials"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 3), "Should show error for invalid credentials.")
    }
    
    func testEmptyFormValidation() throws {
        let continueButton = app.buttons["loginButton"]
        XCTAssertTrue(continueButton.exists)
        continueButton.tap()
        
        let usernameError = app.staticTexts["Please enter a valid username."]
        let passwordError = app.staticTexts["Password cannot be empty."]
        
        XCTAssertTrue(usernameError.waitForExistence(timeout: 2))
        XCTAssertTrue(passwordError.waitForExistence(timeout: 2))
    }
    
    func testNavigateToRegisterView() throws {
        let signUpButton = app.buttons["Sign Up"]
        XCTAssertTrue(signUpButton.exists)
        signUpButton.tap()
        
        let registerView = app.otherElements["RegisterView"]
        XCTAssertTrue(registerView.waitForExistence(timeout: 3), "Should navigate to RegisterView.")
    }
    
    func testBiometricLoginTriggerExists() throws {
        let biometricButton = app.buttons["biometricLoginButton"]
        XCTAssertTrue(biometricButton.exists, "Biometric login button should exist.")
        biometricButton.tap()
        
        let homeScreen = app.otherElements["MainTabView"]
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 5), "Should navigate to MainTabView after biometric login.")
    }
}
