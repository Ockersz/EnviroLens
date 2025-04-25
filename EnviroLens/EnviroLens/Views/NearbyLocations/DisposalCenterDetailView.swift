//
//  DisposalCenterDetailView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-13.
//

import SwiftUI
import CoreLocation
import MapKit

struct DisposalCenterDetailView: View {
    let center: DisposalCenter
    let userLocation: CLLocationCoordinate2D?
    @State private var bounce = false
    
    var body: some View {
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 12) {
                
                Text(center.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityLabel("Disposal Center Name")
                    .accessibilityValue(center.name)
                
                Label("Disposal Center", systemImage: "location.fill")
                    .foregroundColor(.secondary)
                Spacer()
                Label(distanceFromUser(), systemImage: "car.fill")
                    .foregroundColor(.secondary)
                
                
                Divider()
                
                Text("Accepts:")
                    .font(.headline)
                    .accessibilityLabel("Accepted Waste Types")
                
                
               ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(center.acceptedTypes, id: \.self) { type in
                            AcceptedWasteType(type: type, color: colorForType(type))
                        }
                    }
                }
                
                
                Divider()
                
               Text("Operating Hours:")
                    .font(.headline)
                    .accessibilityLabel("Operating Hours")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monday - Friday: \(center.hours.weekday)")
                    Text("Saturday: \(center.hours.saturday)")
                    Text("Sunday: \(center.hours.sunday)")
                }
                .foregroundColor(.secondary)
                
                Button(action: {
                    bounce.toggle()
                    openInMaps()
                }) {
                    Label("Get Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .symbolEffect(.bounce, value: bounce)
                }
                .accessibilityLabel("Get Directions Button")
            }
            .padding()
        }
    }
    
    // Calculate distance from user location
    private func distanceFromUser() -> String {
        guard let userLocation else { return "N/A" }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let centerCLLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        let distanceInMeters = userCLLocation.distance(from: centerCLLocation)
        let distanceInKm = distanceInMeters / 1000.0
        return String(format: "%.1f km", distanceInKm)
    }
    
    // Color based on type
    private func colorForType(_ type: String) -> Color {
        switch type.lowercased() {
            case "paper", "cardboard": return .blue
            case "e-waste", "batteries": return .orange
            case "organic": return .green
            case "plastic": return .purple
            case "glass": return .mint
            case "metal": return .gray
            default: return .teal
        }
    }
    
    //Attempt to get directions in maps
    private func openInMaps() {
        let googleMapsScheme = "comgooglemaps://"
        
        if let googleMapsURL = URL(string: "\(googleMapsScheme)?daddr=\(center.latitude),\(center.longitude)&directionsmode=driving"),
           UIApplication.shared.canOpenURL(URL(string: googleMapsScheme)!) {
            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
        } else {
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: center.coordinate))
            destination.name = center.name
            destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        }
    }
}
