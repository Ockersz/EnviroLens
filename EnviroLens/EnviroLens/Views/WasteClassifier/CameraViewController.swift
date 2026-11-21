//
//  CameraViewController.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-12.
//

import AVFoundation
import Combine
import SwiftUI
import UIKit
import Vision

class CameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var viewModel: CameraViewModel

    private var isProcessingFrame = false
    private let visionQueue = DispatchQueue(label: "visionQueue", qos: .userInitiated)
    private let ciContext = CIContext()
    private lazy var visionModel: VNCoreMLModel? = try? VNCoreMLModel(for: WasterClassifierModel().model)

    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }
    }

    // Setup camera after view loading is done to avoid view breaks
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let session = self?.captureSession, !session.isRunning else { return }
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let session = self?.captureSession, session.isRunning else { return }
            session.stopRunning()
        }
    }

    // Camera setup process - Ensure camera usage permission is granted in Info.plist
    private func setupCamera() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                        for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice)
        else {
            print("Error: Unable to access camera.")
            session.commitConfiguration()
            return
        }

        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: visionQueue)
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.addSublayer(layer)

        session.commitConfiguration()
        self.captureSession = session
        self.previewLayer = layer

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    // Capture the frame and detect the waste product on the image
    func detectAndCaptureFrame(sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.shouldProcessCapture = false
                self?.viewModel.isLoading = false
            }
            return
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.capturedImage = uiImage
            }
        }

        guard let model = visionModel else {
            print("Error: Failed to load ML model.")
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.shouldProcessCapture = false
                self?.viewModel.isLoading = false
            }
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let self = self else { return }
            let results = request.results as? [VNClassificationObservation]
            let firstResult = results?.first

            // Confidence threshold set to 50%
            DispatchQueue.main.async {
                if let top = firstResult, top.confidence > 0.5 {
                    self.viewModel.detectedObjects = top.identifier
                    self.viewModel.confidence = top.confidence
                } else {
                    self.viewModel.detectedObjects = "Unknown"
                    self.viewModel.confidence = 0.0
                }
                self.viewModel.shouldProcessCapture = false
                self.viewModel.isLoading = false
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision request error: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.shouldProcessCapture = false
                self?.viewModel.isLoading = false
            }
        }
    }

    private func updateBrightness(from sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let isDark = computeAverageBrightness(from: ciImage)
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.isDarkBackground = isDark
        }
    }

    // Adjust foreground text color dynamically against live camera luminance
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
        ciContext.render(outputImage,
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

        visionQueue.async { [weak self] in
            guard let self = self else { return }
            self.updateBrightness(from: sampleBuffer)

            if self.viewModel.shouldProcessCapture {
                self.detectAndCaptureFrame(sampleBuffer: sampleBuffer)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.isProcessingFrame = false
            }
        }
    }
}
