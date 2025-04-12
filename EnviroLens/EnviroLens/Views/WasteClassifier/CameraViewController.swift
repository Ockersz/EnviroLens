//
//  CameraViewController.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-12.
//
import SwiftUI
import Combine
import AVFoundation
import Vision
import UIKit

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
