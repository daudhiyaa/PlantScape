//
//  ObjectDetectorViewModel.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import Foundation
import AVKit
import CoreML
import UIKit
import SwiftUI

final class ObjectDetectorViewModel: NSObject, ObservableObject {
    @Published var didDetectObject = false
    
    @Published var deviceHasTorch = false
    @Published var torchActive = false
    
    @AppStorage("objectDetectionEnabled") var objectDetectionEnabled = true
    
    @Published var isShowingAuthRequestView = false
    
    private let detectionManager = ObjectDetectionManager()
    
    private let session = AVCaptureSession()
    private var captureOutput: AVCapturePhotoOutput!
    private var device: AVCaptureDevice!
    
    weak private var objectDelegate: ObjectScannerDelegate?
    
    func setObjectDelegate(_ delegate: ObjectScannerDelegate) {
        self.objectDelegate = delegate
    }
    
    override init() {
        super.init()
        self.detectionManager.setDelegate(self)
    }
    
    let view = UIView(frame: UIScreen.main.bounds)
    
    func toggleTorch() {
        guard let device, deviceHasTorch else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = torchActive ? .off : .on
            device.unlockForConfiguration()
            
            self.torchActive = (device.torchMode == .on ? true : false)
        } catch {
            print("Unable to toggle torch")
        }
    }
    
    func deviceIsAvailable() -> Bool {
        withAnimation {
            return !(self.device == nil)
        }
    }
    
    private func setupSession() {
        self.device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ??
                      AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard let device else {
            print("Device cannot be used")
            return
        }
        
        DispatchQueue.main.async {
            self.deviceHasTorch = device.hasTorch
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            
            guard session.canAddInput(input) else {
                print("Input cannot be added")
                return
            }
            
            session.addInput(input)
            
            DispatchQueue.main.async {
                let preview = AVCaptureVideoPreviewLayer(session: self.session)
                preview.frame = self.view.frame
                preview.videoGravity = .resizeAspectFill
                
                self.view.layer.addSublayer(preview)
            }
            
            createVideoOutput()
            
            session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
        
        restartSession()
    }
    
    private func createVideoOutput() {
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .global(qos: .userInitiated))
        
        guard session.canAddOutput(output) else {
            print("Video Data Output cannot be added")
            return
        }
        
        session.addOutput(output)
        
        self.captureOutput = AVCapturePhotoOutput()
        print(captureOutput.description)
        
        guard session.canAddOutput(captureOutput) else {
            print("Capture output cannot be added")
            return
        }
        
        session.addOutput(captureOutput)
    }
    
    func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { success in
            print("Camera access granted: \(success)")
            guard success else {
                print("Camera access denied")
                return
            }
            self.setupSession()
        }
    }
    
    func checkAuthStatus() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShowingAuthRequestView = true
            }
        case .authorized:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                print("Camera access authorized")
                self.setupSession()
            }
        default:
            break
        }
    }
    
    func restartSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("Scanning restarted")
                self.detectionManager.continueScanning = true
            }
            DispatchQueue.main.async {
                withAnimation {
                    self.didDetectObject = false
                }
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
        }
    }
}

extension ObjectDetectorViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard objectDetectionEnabled else {
            print("Object detection not enabled")
            return
        }
        print("Frame received for processing")
        self.detectionManager.createRequest(for: sampleBuffer)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Frame dropped")
    }
}

extension ObjectDetectorViewModel: ObjectScannerDelegate {
    func didDetectObject(prediction: Prediction?) {
        DispatchQueue.main.async {
            print("Object detected: \(String(describing: prediction))")
            withAnimation {
                self.didDetectObject = true
            }
        }
        stopSession()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.objectDelegate?.didDetectObject(prediction: prediction)
        }
    }
}

