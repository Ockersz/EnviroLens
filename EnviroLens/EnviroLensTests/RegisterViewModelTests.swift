//
//  RegisterViewModelTests.swift
//  EnviroLensTests
//
//  Created by Shahein Ockersz on 2025-04-18.
//

import XCTest
@testable import EnviroLens

final class RegisterViewModelTests: XCTestCase {

    var viewModel: RegisterViewModel!

    override func setUp() {
        super.setUp()
        viewModel = RegisterViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testEmptyFormIsInvalid() {
        XCTAssertFalse(viewModel.isFormValid)
    }

    func testPasswordMismatchFailsValidation() {
        viewModel.name = "John"
        viewModel.username = "john_doe"
        viewModel.email = "john@example.com"
        viewModel.password = "Password123!"
        viewModel.confirmPassword = "WrongPassword!"
        viewModel.selectedArea = "Colombo"
        viewModel.acceptTerms = true

        XCTAssertFalse(viewModel.isFormValid)
    }

    func testMissingAreaFailsValidation() {
        viewModel.name = "John"
        viewModel.username = "john_doe"
        viewModel.email = "john@example.com"
        viewModel.password = "Password123!"
        viewModel.confirmPassword = "Password123!"
        viewModel.selectedArea = "Select Area"
        viewModel.acceptTerms = true

        XCTAssertFalse(viewModel.isFormValid)
    }

    func testTermsNotAcceptedFailsValidation() {
        viewModel.name = "John"
        viewModel.username = "john_doe"
        viewModel.email = "john@example.com"
        viewModel.password = "Password123!"
        viewModel.confirmPassword = "Password123!"
        viewModel.selectedArea = "Kandy"
        viewModel.acceptTerms = false

        XCTAssertFalse(viewModel.isFormValid)
    }

    func testValidFormPassesValidation() {
        viewModel.name = "John"
        viewModel.username = "john_doe"
        viewModel.email = "john@example.com"
        viewModel.password = "Password123!"
        viewModel.confirmPassword = "Password123!"
        viewModel.selectedArea = "Galle"
        viewModel.acceptTerms = true

        XCTAssertTrue(viewModel.isFormValid)
    }

    func testRegistrationFlowMarksAttempted() {
        viewModel.registerUser { }
        XCTAssertTrue(viewModel.attemptedRegister)
    }

    func testAreaListContainsExpectedCities() {
        let expected = ["Colombo", "Galle", "Kandy", "Jaffna", "Matara"]
        XCTAssertEqual(viewModel.areas.sorted(), expected.sorted())
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.registrationSuccess)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "")
    }
}
