import SwiftUI

struct DisposalGuideline: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
}

struct ScanWasteView: View {
    @StateObject var cameraVM = CameraViewModel()
    @State private var selectedBinType: String? = nil
    @State private var guidelines: [DisposalGuideline] = []
    @State private var showGuidelineSheet = false
    @State private var isLoadingGuidelines = false
    
    private func getBinCategory(for wasteType: String) -> String {
        let lowerCaseType = wasteType.lowercased()
        if lowerCaseType.contains("paper") {
            return "paper"
        } else if lowerCaseType.contains("organic") {
            return "organic"
        } else if lowerCaseType.contains("glass") || lowerCaseType.contains("plastic") {
            return "glass_plastic"
        } else {
            return "miscellaneous"
        }
    }
    
    private func isBinEnabled(binType: String) -> Bool {
        let detectedWaste = cameraVM.detectedObjects.lowercased()
        if detectedWaste.isEmpty {
            return true
        }
        let binCategory = getBinCategory(for: detectedWaste)
        return binCategory == binType
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera or Captured Frame
                if let frozenImage = cameraVM.capturedImage {
                    Image(uiImage: frozenImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(edges: .all)
                        .accessibilityIdentifier("CapturedImage")
                        .accessibilityLabel("Captured Image Preview") // Add accesebility labels for voice over
                } else {
                    CameraPreview(viewModel: cameraVM)
                        .edgesIgnoringSafeArea(.top)
                        .accessibilityIdentifier("CameraPreview")
                        .accessibilityLabel("Live camera preview")
                }
                
                VStack {
                    Spacer().frame(height: 60)
                    
                    if !cameraVM.detectedObjects.isEmpty && !cameraVM.isLoading {
                        VStack {
                            Text(cameraVM.detectedObjects)
                                .font(.headline)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                                .accessibilityIdentifier("DetectedWasteLabel")
                                .accessibilityLabel("Detected waste type")
                                .accessibilityValue(cameraVM.detectedObjects)
                                .accessibilityHint("This is the detected waste object")
                            
                            Text("Confidence: \(String(format: "%.2f", cameraVM.confidence * 100))%")
                                .font(.subheadline)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                                .accessibilityIdentifier("ConfidenceLabel")
                                .accessibilityLabel("Detection confidence")
                                .accessibilityValue("\(String(format: "%.0f", cameraVM.confidence * 100)) percent")
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 70) {
                        Button(action: {
                            cameraVM.capture()
                        }) {
                            Text("Capture")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .foregroundColor(.white)
                                .background(Color("PrBtnCol"))
                                .cornerRadius(8)
                        }
                        .accessibilityIdentifier("CaptureButton")
                        .accessibilityLabel("Capture button")
                        .accessibilityHint("Tap to capture the current image from the camera")
                        
                        Button(action: {
                            cameraVM.reset()
                        }) {
                            Text("Reset")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                        .accessibilityIdentifier("ResetButton")
                        .accessibilityLabel("Reset button")
                        .accessibilityHint("Tap to reset the camera and clear detection")
                    }
                    .frame(width: 300)
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        if !cameraVM.detectedObjects.isEmpty && !cameraVM.isLoading {
                            let detectedCategory = getBinCategory(for: cameraVM.detectedObjects)
                            Text("Please dispose in the \(detectedCategory.replacingOccurrences(of: "_", with: "/").capitalized) bin")
                                .font(.headline)
                                .padding(.bottom, 10)
                                .foregroundColor(.green)
                                .accessibilityLabel("Dispose recommendation")
                                .accessibilityValue("Please dispose in the \(detectedCategory.replacingOccurrences(of: "_", with: " ")) bin")
                        } else {
                            Text("Let us help you sort your waste.")
                                .font(.headline)
                                .padding(.bottom, 10)
                                .accessibilityLabel("No detection yet")
                        }
                        
                        HStack(spacing: 10) {
                            binType(imageName: "RCanBrwn", label: "Organic", typeKey: "organic")
                                .opacity(isBinEnabled(binType: "organic") ? 1.0 : 0.4)
                                .disabled(!isBinEnabled(binType: "organic"))
                            
                            binType(imageName: "RCanBlu", label: "Paper", typeKey: "paper")
                                .opacity(isBinEnabled(binType: "paper") ? 1.0 : 0.4)
                                .disabled(!isBinEnabled(binType: "paper"))
                            
                            binType(imageName: "RCanBlck", label: "Glass/plastic", typeKey: "glass_plastic")
                                .opacity(isBinEnabled(binType: "glass_plastic") ? 1.0 : 0.4)
                                .disabled(!isBinEnabled(binType: "glass_plastic"))
                            
                            binType(imageName: "RCanGr", label: "Miscellaneous", typeKey: "miscellaneous")
                                .opacity(isBinEnabled(binType: "miscellaneous") ? 1.0 : 0.4)
                                .disabled(!isBinEnabled(binType: "miscellaneous"))
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .padding(.bottom, 30)
                }
                .padding()
                
                if cameraVM.isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView("Processing...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .accessibilityIdentifier("ProcessingIndicator")
                            .accessibilityLabel("Processing")
                    }
                }
                
                // Implement a shutter falsh to show that the image is captured.
                if cameraVM.showShutterFlash {
                    Color.white
                        .opacity(0.8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.2), value: cameraVM.showShutterFlash)
                        .accessibilityIdentifier("ShutterFlash")
                        .accessibilityLabel("Camera shutter flash")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Scan Waste")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(cameraVM.isDarkBackground ? .white : .black)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("Understand the waste you're recycling")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(cameraVM.isDarkBackground ? .white : .black)
                    }
                    .padding(.top)
                }
            }
            .sheet(isPresented: $showGuidelineSheet) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\((selectedBinType ?? "").replacingOccurrences(of: "_", with: " ").capitalized) Waste Disposal Guideline")
                        .font(.title3.bold())
                        .padding(.top)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Guidelines for \(selectedBinType ?? "") waste")
                    
                    if isLoadingGuidelines {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                            .accessibilityIdentifier("GuidelineLoadingIndicator")
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(guidelines) { guide in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(guide.title)
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)
                                            .accessibilityLabel(guide.title)
                                        
                                        Text(guide.description)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                            .accessibilityLabel(guide.description)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 16)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    .padding(.bottom, 12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .scrollIndicators(.visible)
                        .accessibilityIdentifier("GuidelineScrollView")
                    }
                }
                .padding(.bottom, 16)
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    func binType(imageName: String, label: String, typeKey: String) -> some View {
        Button {
            fetchGuidelines(for: typeKey)
        } label: {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) bin")
        .accessibilityHint("Tap to view guidelines for \(label) waste")
        .accessibilityIdentifier("\(typeKey)BinButton")
    }
    
    //Get guidlines based on the clicked bin.
    func fetchGuidelines(for binType: String) {
        guard let url = URL(string: "https://us-central1-envirolens-2ca53.cloudfunctions.net/getBinDisposalGuidlines?type=\(binType)") else {
            print("Invalid URL")
            return
        }
        
        isLoadingGuidelines = true
        selectedBinType = binType
        guidelines = []
        showGuidelineSheet = true
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching guidelines: \(error)")
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            do {
                let response = try JSONDecoder().decode([DisposalGuideline].self, from: data)
                DispatchQueue.main.async {
                    self.guidelines = response
                    self.isLoadingGuidelines = false
                }
            } catch {
                print("Decoding error: \(error)")
                isLoadingGuidelines = false
            }
        }.resume()
    }
}
