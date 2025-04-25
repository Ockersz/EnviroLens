//
//  LocationViewModelTests.swift
//  EnviroLensTests
//
//  Created by Shahein Ockersz on 2025-04-18.
//

import XCTest
import MapKit
@testable import EnviroLens

final class LocationViewModelTests: XCTestCase {
    
    var viewModel: LocationViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = LocationViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialRegionIsColombo() {
        let expectedLatitude: CLLocationDegrees = 6.9271
        let expectedLongitude: CLLocationDegrees = 79.8612
        
        XCTAssertEqual(viewModel.region.center.latitude, expectedLatitude, accuracy: 0.0001)
        XCTAssertEqual(viewModel.region.center.longitude, expectedLongitude, accuracy: 0.0001)
    }

    func testLocationManagerDidUpdateLocationSetsUserLocationAndRegion() {
        let expectation = XCTestExpectation(description: "User location is set")
        
        let testLocation = CLLocation(latitude: 7.0, longitude: 80.0)
        viewModel.locationManager(CLLocationManager(), didUpdateLocations: [testLocation])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let userLocation = self.viewModel.userLocation else {
                XCTFail("userLocation is nil")
                return
            }
            
            XCTAssertEqual(userLocation.latitude, 7.0, accuracy: 0.1)
            XCTAssertEqual(self.viewModel.region.center.latitude, 7.0, accuracy: 0.1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }




    func testLocationManagerDidFailFallbacksToColombo() {
        viewModel.locationManager(CLLocationManager(), didFailWithError: NSError(domain: "", code: 0))

        XCTAssertEqual(viewModel.region.center.latitude, 6.9271, accuracy: 0.0001)
        XCTAssertEqual(viewModel.region.center.longitude, 79.8612, accuracy: 0.0001)
    }

    func testFetchDisposalCentersFromLiveServer() {
        let expectation = XCTestExpectation(description: "Fetch disposal centers from live server")
        
        let viewModel = LocationViewModel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let centers = viewModel.disposalCenters
            XCTAssertFalse(centers.isEmpty, "Expected at least one disposal center from server.")
            
            let expectedNames = [
                "Colombo Municipal Waste Center",
                "Borella Recycling Yard",
                "Wellawatte E-Waste Center"
            ]
            
            for expected in expectedNames {
                XCTAssertTrue(centers.contains(where: { $0.name == expected }),
                              "Expected to find center named '\(expected)'")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
