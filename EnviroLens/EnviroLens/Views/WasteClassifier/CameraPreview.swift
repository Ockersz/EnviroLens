//
//  CameraPreview.swift
//  EnviroLens
//
//  Created by Shahein Ockersz on 2025-04-12.
//
import SwiftUI
import Combine
import AVFoundation
import Vision
import UIKit


struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}
