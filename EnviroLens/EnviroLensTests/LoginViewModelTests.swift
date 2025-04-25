//
//  LoginViewModelTests.swift
//  EnviroLensTests
//
//  Created by Shahein Ockersz on 2025-04-18.
//

import XCTest
@testable import EnviroLens

class MockAuthViewModel: AuthViewModel {
    var shouldSucceed = true
    var signInCalled = false
    
    override func signInWithUsername(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        signInCalled = true
        if shouldSucceed {
            completion(true, nil)
        } else {
            let error = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
            completion(false, error)
        }
    }
}

final class LoginViewModelTests: XCTestCase {
    
    func testInvalidUsernameFailsValidation() {
        let mockAuth = AuthViewModel()
        let viewModel = LoginViewModel(authViewModel: mockAuth)
        viewModel.username = "x"
        viewModel.password = "password123"
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testValidFormPassesValidation() {
        let mockAuth = AuthViewModel()
        let viewModel = LoginViewModel(authViewModel: mockAuth)
        viewModel.username = "valid_user"
        viewModel.password = "securePassword"
        XCTAssertTrue(viewModel.isFormValid)
    }
    
    func testEmptyFieldsFailValidation() {
        let viewModel = LoginViewModel(authViewModel: AuthViewModel())
        viewModel.username = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testOnlyUsernameFilledFailsValidation() {
        let viewModel = LoginViewModel(authViewModel: AuthViewModel())
        viewModel.username = "valid_user"
        viewModel.password = ""
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testOnlyPasswordFilledFailsValidation() {
        let viewModel = LoginViewModel(authViewModel: AuthViewModel())
        viewModel.username = ""
        viewModel.password = "securePassword"
        XCTAssertFalse(viewModel.isFormValid)
    }
    
    func testHandleLoginSetsAttemptedLoginTrue() {
        let viewModel = LoginViewModel(authViewModel: AuthViewModel())
        viewModel.username = "user"
        viewModel.password = ""
        viewModel.handleLogin()
        XCTAssertTrue(viewModel.attemptedLogin)
    }
    
    func testLoginWithInvalidFormDoesNotProceed() {
        let viewModel = LoginViewModel(authViewModel: AuthViewModel())
        viewModel.username = "invalid"
        viewModel.password = ""
        viewModel.handleLogin()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "")
        XCTAssertFalse(viewModel.navigateToHome)
    }
    
    func testSuccessfulLoginUpdatesState() {
        let mockAuth = MockAuthViewModel()
        mockAuth.shouldSucceed = true
        let viewModel = LoginViewModel(authViewModel: mockAuth)
        viewModel.username = "valid_user"
        viewModel.password = "securePassword"
        
        let expectation = XCTestExpectation(description: "Login success")
        
        viewModel.handleLogin()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(mockAuth.signInCalled)
            XCTAssertTrue(viewModel.navigateToHome)
            XCTAssertFalse(viewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailedLoginSetsErrorMessage() {
        let mockAuth = MockAuthViewModel()
        mockAuth.shouldSucceed = false
        let viewModel = LoginViewModel(authViewModel: mockAuth)
        viewModel.username = "user"
        viewModel.password = "wrongpass"
        
        let expectation = XCTestExpectation(description: "Login failure")
        
        viewModel.handleLogin()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(mockAuth.signInCalled)
            XCTAssertEqual(viewModel.errorMessage, "Mock error")
            XCTAssertFalse(viewModel.navigateToHome)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
