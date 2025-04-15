//
//  QRScannerView.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-13.
//


import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: QRScannerView

        init(_ parent: QRScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            if let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               metadata.type == .qr,
               let code = metadata.stringValue {
                parent.onScan(code)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        let session = AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return vc }
        
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]
        }
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = UIScreen.main.bounds
        preview.videoGravity = .resizeAspectFill
        vc.view.layer.addSublayer(preview)
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        return vc
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
