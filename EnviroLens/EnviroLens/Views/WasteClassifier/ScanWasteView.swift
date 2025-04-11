//
//  ScanWasteView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-03-27.
//

import SwiftUI
import Combine
import AVFoundation
import Vision
import UIKit

// MARK: - CameraViewModel
class CameraViewModel: ObservableObject {
    @Published var detectedObjects: String = ""
    @Published var confidence: Float = 0.0
    @Published var boundingBox: CGRect = .zero
    @Published var isLoading: Bool = false
    @Published var shouldProcessCapture: Bool = false
    @Published var capturedImage: UIImage? = nil
    @Published var isDarkBackground: Bool = false
    @Published var showShutterFlash: Bool = false
    
    func capture() {
        showShutterFlash = true
        shouldProcessCapture = true
        isLoading = true
        
        // Reset shutter after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.showShutterFlash = false
        }
    }
    
    func reset() {
        detectedObjects = ""
        confidence = 0.0
        boundingBox = .zero
        capturedImage = nil
    }
}

// MARK: - CameraPreview
struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}

// MARK: - CameraViewController
class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var viewModel: CameraViewModel
    private var isProcessingFrame = false
    private let visionQueue = DispatchQueue(label: "visionQueue", qos: .userInitiated)
    
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
        else {
            print("Error: Unable to access camera.")
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: visionQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        captureSession.commitConfiguration()
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    func detectAndCaptureFrame(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            DispatchQueue.main.async {
                self.viewModel.capturedImage = uiImage
            }
        }
        
        guard let model = try? VNCoreMLModel(for: WasterClassifierModel().model) else {
            print("Error: Failed to load ML model.")
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                  let firstResult = results.first,
                  let self = self else { return }
            
            DispatchQueue.main.async {
                if firstResult.confidence > 0.5 {
                    self.viewModel.detectedObjects = firstResult.identifier
                    self.viewModel.confidence = firstResult.confidence
                } else {
                    self.viewModel.detectedObjects = "Unknown"
                    self.viewModel.confidence = 0.0
                }
                self.viewModel.shouldProcessCapture = false
                self.viewModel.isLoading = false
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    private func updateBrightness(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let isDark = computeAverageBrightness(from: ciImage)
        DispatchQueue.main.async {
            self.viewModel.isDarkBackground = isDark
        }
    }
    
    private func computeAverageBrightness(from image: CIImage) -> Bool {
        let extent = image.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: image,
                                                kCIInputExtentKey: inputExtent]),
              let outputImage = filter.outputImage else {
            return false
        }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext()
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        
        let brightness = (0.299 * Double(bitmap[0]) +
                          0.587 * Double(bitmap[1]) +
                          0.114 * Double(bitmap[2])) / 255.0
        
        return brightness < 0.50
    }
}

// MARK: - Frame Processing
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        if isProcessingFrame { return }
        isProcessingFrame = true
        
        visionQueue.async {
            self.updateBrightness(from: sampleBuffer)
            
            if self.viewModel.shouldProcessCapture {
                self.detectAndCaptureFrame(sampleBuffer: sampleBuffer)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isProcessingFrame = false
            }
        }
    }
}

// MARK: - ScanWasteView (Main UI)
struct ScanWasteView: View {
    @StateObject var cameraVM = CameraViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Camera or Captured Frame
                if let frozenImage = cameraVM.capturedImage {
                    Image(uiImage: frozenImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    CameraPreview(viewModel: cameraVM)
                        .ignoresSafeArea()
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
                            Text("Confidence: \(String(format: "%.2f", cameraVM.confidence * 100))%")
                                .font(.subheadline)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Buttons
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
                        
                        Button(action: {
                            cameraVM.reset()
                        }) {
                            Text("Reset")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .foregroundColor(.white)
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                    }
                    .frame(width: 300)
                    .padding(.bottom, 20)
                    
                    VStack(alignment: .leading) {
                        Text("Let us help you sort your waste.")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        HStack(spacing: 10) {
                            binType(imageName: "RCanBrwn", label: "Organic")
                            binType(imageName: "RCanBlu", label: "Paper")
                            binType(imageName: "RCanBlck", label: "Glass/plastic")
                            binType(imageName: "RCanGr", label: "Miscellaneous")
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
                    }
                }
                
                // Shutter Flash Effect
                if cameraVM.showShutterFlash {
                    Color.white
                        .opacity(0.8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .animation(.easeOut(duration: 0.2), value: cameraVM.showShutterFlash)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Scan Waste")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(cameraVM.isDarkBackground ? .white : .black)
                        Text("Understand the waste you're recycling")
                            .font(.body)
                            .fontWeight(.light)
                            .foregroundColor(cameraVM.isDarkBackground ? .white : .black)
                    }
                    .padding(.top)
                }
            }
        }
    }
    
    func binType(imageName: String, label: String) -> some View {
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
}

#Preview {
    ScanWasteView()
}
