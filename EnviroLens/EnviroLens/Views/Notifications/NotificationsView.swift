//
//  NotificationsView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-15.
//

import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = false
    @State private var showClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading notifications...")
                        .padding()
                } else if notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No notifications")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(notifications) { notification in
                            HStack(alignment: .top, spacing: 12) {
                          
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.headline)
                                    Text(notification.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(notification.timestamp)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !notifications.isEmpty {
                        Button("Clear All") {
                            showClearConfirmation = true
                        }
                        .foregroundStyle(.gray)
                    }
                }
            }
            .confirmationDialog("Clear all notifications?", isPresented: $showClearConfirmation, titleVisibility: .visible) {
                Button("Clear All", role: .destructive) {
                    notifications.removeAll()
                }
                Button("Cancel", role: .cancel) { }
            }
            .onAppear {
                fetchNotifications()
            }
        }
    }
    
    func fetchNotifications() {
        isLoading = true
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/getNotifications") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode([NotificationItem].self, from: data)
                DispatchQueue.main.async {
                    self.notifications = result
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
    
    func deleteItems(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
}

struct NotificationItem: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let description: String
    let timestamp: String
}
