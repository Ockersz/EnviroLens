//
//  WasteClassifier.swift
//  EnviroLensTests
//
//  Created by Shahein Ockersz on 2025-04-15.
//

import XCTest

final class ScanViewUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        // Stop immediately when a failure occurs
        continueAfterFailure = false
        
        // Configure the app for UI testing
        app.launchArguments = ["-UITestMode"]
        app.launchEnvironment = ["UITesting": "1"]
        app.launch()
        
        // Login using username and password before continuing
        loginWithUsernameAndPassword(username: "shahein", password: "Ockersz@$5")
    }
    
    override func tearDownWithError() throws {
        // Cleanup code after tests
    }
    
    func testCameraFeedIsDisplayed() throws {
        // Navigate to the ScanView
        app.buttons["Scan"].tap()
        
        // Check if the camera feed is displayed
        let cameraFeed = app.otherElements["CameraPreview"]
        XCTAssertTrue(cameraFeed.exists, "The camera preview should be displayed.")
    }
    
    // Function to simulate login with username and password
    func loginWithUsernameAndPassword(username: String, password: String) {
        // Ensure the username field is present and enter the username
        let usernameField = app.textFields["Username"]
        XCTAssertTrue(usernameField.exists, "The username text field should exist on the login screen.")
        usernameField.tap()
        usernameField.typeText(username)
        
        // Ensure the password field is present and enter the password
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists, "The password text field should exist on the login screen.")
        passwordField.tap()
        passwordField.typeText(password)
        
        // Tap the Continue button to log in
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.exists, "The Continue button should exist on the login screen.")
        continueButton.tap()
        
        // Wait for navigation to the home screen
        let homeScreenElement = app.otherElements["MainTabView"]
        let exists = homeScreenElement.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "The app should navigate to the home screen after successful login.")
    }
}
