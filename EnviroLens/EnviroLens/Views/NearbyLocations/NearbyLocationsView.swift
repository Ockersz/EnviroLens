//
//  NearbyLocationsView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-12.
//

import SwiftUI
import MapKit

struct NearbyLocationsView: View {
    @StateObject private var viewModel = LocationViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var mapRect = MKMapRect.world
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map {
                    UserAnnotation()
                    
                    ForEach(viewModel.disposalCenters) { center in
                        Annotation(center.name, coordinate: center.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                                .clipShape(Circle())
                                .onTapGesture {
                                    viewModel.selectedCenter = center
                                }
                        }
                        .annotationTitles(.hidden)
                    }
                }
                .mapControls {
                    MapCompass()
                    MapPitchToggle()
                    MapUserLocationButton()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Nearby Locations")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    .padding(.bottom)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }
                }
            }
            .sheet(item: $viewModel.selectedCenter) { center in
                DisposalCenterDetailView(center: center, userLocation: viewModel.userLocation)
                    .presentationDetents([.medium, .large])
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
