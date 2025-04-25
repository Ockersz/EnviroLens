//
//  MyBinsView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-14.
//

import SwiftUI
import UserNotifications

struct MyBinsView: View {
    @State private var isLoading = false
    @State private var binGroups: [BinGroup] = []
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var showLabelPrompt = false
    @State private var newBinLabel = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        if isLoading {
                            ProgressView("Fetching bin status...")
                                .padding(.top)
                        } else {
                            ForEach(binGroups) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.location)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(group.bins) { bin in
                                                VStack(spacing: 6) {
                                                    Image(bin.iconName)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 60, height: 60)
                                                    
                                                    Text(bin.type)
                                                        .font(.caption)
                                                    
                                                    Text("\(bin.fillLevel) %")
                                                        .font(.caption)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(colorForPercentage(bin.fillLevel))
                                                }
                                                .frame(width: 90, height: 100)
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
                                    }
                                    .frame(height: 120)
                                    .padding(.horizontal)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(.top)
                }
                
                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isScanning = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding()
                        .accessibilityLabel("Add Bin")
                    }
                }
            }
            .navigationTitle("My Bins")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isScanning) {
                QRScannerView { code in
                    scannedCode = code
                    isScanning = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showLabelPrompt = true
                    }
                }
            }
            .alert("Name Your Bin Group", isPresented: $showLabelPrompt) {
                TextField("e.g., Garage", text: $newBinLabel)
                Button("Add") {
                    if let code = scannedCode, !newBinLabel.trimmingCharacters(in: .whitespaces).isEmpty {
                        addBinForQRCode(code, withLabel: newBinLabel)
                        newBinLabel = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    newBinLabel = ""
                }
            }
            .onAppear {
                requestNotificationPermission()
                fetchBinGroups()
            }
        }
    }
    
    func fetchBinGroups() {
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/getSmartBins") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Fetch error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([BinGroup].self, from: data)
                DispatchQueue.main.async {
                    self.binGroups = decoded
                    let hasFullBin = decoded.flatMap { $0.bins }.contains { $0.fillLevel > 70 }
                    if hasFullBin {
                        sendFullBinAlert()
                    }
                }
            } catch {
                print("Decode error: \(error)")
            }
        }.resume()
    }
    
    func addBinForQRCode(_ code: String, withLabel label: String) {
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/addSmartBin") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = [
            "code": code,
            "label": label
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Failed to serialize request body")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Add error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data from server")
                return
            }
            
            do {
                let newGroup = try JSONDecoder().decode([BinGroup].self, from: data)
                DispatchQueue.main.async {
                    self.binGroups = newGroup
                    self.newBinLabel = ""
                }
            } catch {
                print("Decode error: \(error)")
            }
        }.resume()
    }
    
    func colorForPercentage(_ percent: Int) -> Color {
        switch percent {
            case 0..<40: return .green
            case 40..<70: return .orange
            default: return .red
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Permission error: \(error)")
            }
        }
    }
    
    func sendFullBinAlert() {
        let content = UNMutableNotificationContent()
        content.title = "Bin Almost Full"
        content.body = "One or more of your bins are over 70% full. Consider emptying them soon."
        content.sound = .defaultCriticalSound(withAudioVolume: 100)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: \(error.localizedDescription)")
            }
        }
    }
}

struct BinGroup: Identifiable, Codable {
    let id = UUID()
    let location: String
    let bins: [BinStatus]
}

struct BinStatus: Identifiable, Codable {
    let id = UUID()
    let type: String
    let fillLevel: Int
    let iconName: String
}
