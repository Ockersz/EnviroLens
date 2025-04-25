//
//  CameraViewModel.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-12.
//
import SwiftUI
import Combine
import AVFoundation
import Vision
import UIKit

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
