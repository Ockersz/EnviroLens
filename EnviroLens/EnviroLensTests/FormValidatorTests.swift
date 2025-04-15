//
//  FormValidatorTests.swift
//  EnviroLensTests
//
//  Created by Shahein Ockersz on 2025-04-15.
//

import XCTest
@testable import EnviroLens

final class FormValidatorTests: XCTestCase {
    
    // MARK: - isValidName
    
    func testValidNameShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isValidName("Shahein"))
    }
    
    func testEmptyNameShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isValidName("   "))
    }
    
    // MARK: - isValidUsername
    
    func testValidUsernameShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isValidUsername("Shahein_123"))
    }
    
    func testShortUsernameShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isValidUsername("a"))
    }
    
    func testInvalidCharactersInUsernameShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isValidUsername("Shahein!@#"))
    }
    
    // MARK: - isUsernameAllowed
    
    func testAllowedUsernameShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isUsernameAllowed("shahein"))
    }
    
    func testReservedUsernameShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isUsernameAllowed("admin"))
        XCTAssertFalse(FormValidator.isUsernameAllowed("SUPPORT"))
    }
    
    // MARK: - isValidEmail
    
    func testValidEmailShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isValidEmail("shahein@example.com"))
    }
    
    func testInvalidEmailShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isValidEmail("shahein.com"))
        XCTAssertFalse(FormValidator.isValidEmail("user@.com"))
    }
    
    // MARK: - isValidPassword
    
    func testValidLengthPasswordShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isValidPassword("abcdefgh"))
    }
    
    func testShortPasswordShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isValidPassword("abc"))
    }
    
    // MARK: - isStrongPassword
    
    func testStrongPasswordShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isStrongPassword("Strong@123"))
    }
    
    func testWeakPasswordShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isStrongPassword("weakpass"))
        XCTAssertFalse(FormValidator.isStrongPassword("nouppercase@1"))
        XCTAssertFalse(FormValidator.isStrongPassword("NoNumber!"))
        XCTAssertFalse(FormValidator.isStrongPassword("noSymbol123"))
    }
    
    // MARK: - passwordsMatch
    
    func testMatchingPasswordsShouldReturnTrue() {
        XCTAssertTrue(FormValidator.passwordsMatch("Password123", "Password123"))
    }
    
    func testMismatchingPasswordsShouldReturnFalse() {
        XCTAssertFalse(FormValidator.passwordsMatch("Password123", "password123"))
    }
    
    // MARK: - isNotBlank
    
    func testNonEmptyInputShouldReturnTrue() {
        XCTAssertTrue(FormValidator.isNotBlank("Some text"))
    }
    
    func testEmptyInputShouldReturnFalse() {
        XCTAssertFalse(FormValidator.isNotBlank("   "))
        XCTAssertFalse(FormValidator.isNotBlank(""))
    }
}
