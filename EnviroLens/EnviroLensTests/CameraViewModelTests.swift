//
//  CameraViewModelTests.swift
//  EnviroLensTests
//
//  Created by Shahein Ockersz on 2025-04-18.
//

import XCTest
@testable import EnviroLens
import UIKit

final class CameraViewModelTests: XCTestCase {
    
    var viewModel: CameraViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = CameraViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialStateIsClean() {
        XCTAssertEqual(viewModel.detectedObjects, "")
        XCTAssertEqual(viewModel.confidence, 0.0)
        XCTAssertEqual(viewModel.boundingBox, .zero)
        XCTAssertNil(viewModel.capturedImage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.shouldProcessCapture)
        XCTAssertFalse(viewModel.showShutterFlash)
        XCTAssertFalse(viewModel.isDarkBackground)
    }

    func testCaptureUpdatesStateCorrectly() {
        let expectation = XCTestExpectation(description: "Shutter flash should reset")

        viewModel.capture()
        
        XCTAssertTrue(viewModel.showShutterFlash)
        XCTAssertTrue(viewModel.shouldProcessCapture)
        XCTAssertTrue(viewModel.isLoading)

        // Wait for shutter flash reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            XCTAssertFalse(self.viewModel.showShutterFlash)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testResetClearsDetectionData() {
        viewModel.detectedObjects = "Bottle"
        viewModel.confidence = 0.89
        viewModel.boundingBox = CGRect(x: 10, y: 10, width: 100, height: 100)
        viewModel.capturedImage = UIImage(systemName: "camera.fill")
        
        viewModel.reset()
        
        XCTAssertEqual(viewModel.detectedObjects, "")
        XCTAssertEqual(viewModel.confidence, 0.0)
        XCTAssertEqual(viewModel.boundingBox, .zero)
        XCTAssertNil(viewModel.capturedImage)
    }
}
