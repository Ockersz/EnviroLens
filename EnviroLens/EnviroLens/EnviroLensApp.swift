//
//  EnviroLensApp.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-03-27.
//

import SwiftUI

@main
struct EnviroLensApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
