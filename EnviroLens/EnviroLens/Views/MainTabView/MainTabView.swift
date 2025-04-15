//
//  MainTabView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-10.
//
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
                .tag(0)
            
            ScanWasteView()
                .tabItem {
                    VStack {
                        Image(systemName: "camera.fill")
                        Text("Scan")
                    }
                }
                .tag(1)
            
            NearbyLocationsView()
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Find")
                    }
                }
                .tag(2)
            
            DisposeView()
                .tabItem {
                    VStack {
                        Image(systemName: "trash.fill")
                        Text("Dispose")
                    }
                }
                .tag(3)
            
            ScanWasteView()
                .tabItem {
                    VStack {
                        Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        Text("Redeem")
                    }
                }
                .tag(4)
        }
        .accentColor(Color("PrBtnCol"))
    }
}
