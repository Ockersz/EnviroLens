//
//  DisposeView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-13.
//


import SwiftUI
import AVFoundation

struct DisposeView: View {
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var disposalHistory: [DisposalEntry] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 20)
                    Button {
                        isScanning = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color.green.opacity(0.5))
                                .padding()
                                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
                            
                            Text("Scan to connect to disposal center")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let code = scannedCode {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Connected to: \(code)")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                Spacer()
                                Button(role: .destructive) {
                                    scannedCode = nil
                                    disposalHistory.removeAll()
                                } label: {
                                    Label("Clear", systemImage: "xmark.circle.fill")
                                        .labelStyle(.iconOnly)
                                        .foregroundColor(.red)
                                }
                                .accessibilityLabel("Clear scanned disposal center")
                            }
                            .padding(.top)
                            .padding(.horizontal)
                        }
                    }
                    
                    // History
                    if isLoading {
                        ProgressView("Fetching history...")
                            .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            if !disposalHistory.isEmpty {
                                Text("Your History")
                                    .font(.headline)
                                    .padding(.horizontal)
                            }
                            
                            ForEach(disposalHistory, id: \.id) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(entry.categories) { category in
                                                VStack(spacing: 6) {
                                                    Image(uiImage: category.icon)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 50, height: 50)
                                                    
                                                    Text(category.type)
                                                        .font(.caption)
                                                    
                                                    Text("\(category.weight) KG")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                }
                                                .frame(width: 90, height: 100)
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Dispose")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Scan to connect to disposal center")
                            .font(.body)
                            .fontWeight(.light)                    }
                    .padding(.top)
                }
            }
            .sheet(isPresented: $isScanning) {
                QRScannerView { code in
                    self.scannedCode = code
                    self.isScanning = false
                    fetchDisposalHistory(for: code)
                }
            }
        }
    }
    
    func fetchDisposalHistory(for code: String) {
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/getDisposalHistory?code=\(code)") else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                print("Error fetching: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([DisposalEntry].self, from: data)
                DispatchQueue.main.async {
                    self.disposalHistory = decoded
                }
            } catch {
                print("Decoding failed: \(error)")
            }
        }.resume()
    }
}


struct DisposalEntry: Codable, Identifiable {
    let id = UUID()
    let date: String
    let categories: [WasteCategory]
}

struct WasteCategory: Identifiable, Codable {
    let id = UUID()
    let type: String
    let weight: Int
    let iconName: String
    
    var icon: UIImage {
        UIImage(named: iconName) ?? UIImage(systemName: "questionmark.square.dashed")!
    }
}
