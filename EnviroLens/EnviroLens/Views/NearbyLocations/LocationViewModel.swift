//
//  LocationViewModel.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-13.
//

import SwiftUI
import MapKit

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var disposalCenters: [DisposalCenter] = []
    @Published var region: MKCoordinateRegion
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCenter: DisposalCenter?
    @Published var userLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    private let session: URLSession
    
    private let gotoColomboRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    init(session: URLSession = .shared) {
        self.session = session
        _region = Published(initialValue: gotoColomboRegion)
        super.init()
        setupLocationManager()
        fetchDisposalCenters()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
            self.region = MKCoordinateRegion(
                center: latestLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.region = self.gotoColomboRegion
        }
    }
    
    func fetchDisposalCenters() {
        isLoading = true
        
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/getDisposalCenters") else {
            isLoading = false
            return
        }
        
        session.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            if let error = error {
                print("Error fetching disposal centers: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            do {
                let centers = try JSONDecoder().decode([DisposalCenter].self, from: data)
                DispatchQueue.main.async {
                    self.disposalCenters = centers
                }
            } catch {
                print("Error decoding disposal centers: \(error)")
            }
        }.resume()
    }
}
