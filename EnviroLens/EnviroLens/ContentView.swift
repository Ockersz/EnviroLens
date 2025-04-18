//
//  ContentView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-03-27.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some View{
        NavigationStack{
            if authViewModel.user != nil {
                MainTabView()
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
    }
}
