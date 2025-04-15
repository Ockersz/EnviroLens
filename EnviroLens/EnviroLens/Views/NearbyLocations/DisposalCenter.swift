//
//  DisposalCenter.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-13.
//
import MapKit

struct DisposalCenter: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let acceptedTypes: [String] // ✅ now supports multiple types
    let hours: Hours
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    struct Hours: Codable {
        let weekday: String
        let saturday: String
        let sunday: String
    }
}
