//
//  EnviroLensApp.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-03-27.
//

import SwiftUI
import Firebase
import UserNotifications

@main
struct EnviroLensApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(authViewModel)
         
        }
    }
}
