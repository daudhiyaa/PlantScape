//
//  ObjectDetectionManager.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import Foundation
import Vision

class ObjectDetectionManager {
    var continueScanning = true
    private var request: VNCoreMLRequest?
    private var predictionBuffer: [String] = [] // Buffer to store predictions
    private let bufferSize = 10 // Number of frames to collect
    private let confidenceThreshold = 0.6 // Confidence threshold for detection
    private let matchThreshold = 5 // Number of matches required

    init() {
        self.setupRequest()
    }
    
    weak private var scannerDelegate: ObjectScannerDelegate?
    
    func setDelegate(_ delegate: ObjectScannerDelegate) {
        self.scannerDelegate = delegate
    }
    
    private func setupRequest() {
        guard let model = try? VNCoreMLModel(for: PlantDetectionModel(configuration: MLModelConfiguration()).model) else {
            fatalError("Unable to configure PlantDetectionModel")
        }
        
        self.request = VNCoreMLRequest(model: model, completionHandler: requestCompleted)
    }
    
    private func requestCompleted(request: VNRequest, err: Error?) {
        guard let results = request.results as? [VNRecognizedObjectObservation],
              let prediction = results.first,
              err == nil,
              continueScanning else {
            return
        }
        
        guard let predictionLabel = prediction.labels.first else {
            return
        }

        // Add prediction to buffer
        predictionBuffer.append(predictionLabel.identifier)

        // If buffer is full, process the predictions
        if predictionBuffer.count >= bufferSize {
            processBuffer()
        }
    }
    
    private func processBuffer() {
        let predictionCounts = predictionBuffer.reduce(into: [:]) { counts, identifier in
            counts[identifier, default: 0] += 1
        }
        
        let sortedPredictions = predictionCounts.sorted { $0.value > $1.value }
        if let bestPrediction = sortedPredictions.first, bestPrediction.value >= matchThreshold {
            continueScanning = false
            scannerDelegate?.didDetectObject(prediction: Prediction(identifier: bestPrediction.key))
        }
        
        // Clear the buffer
        predictionBuffer.removeAll()
    }
    
    func createRequest(for buffer: CMSampleBuffer) {
        do {
            guard let pixelBuffer = try? CMSampleBuffer(copying: buffer), let request else {
                print("Unable to create request")
                return
            }
            
            let imageRequest = VNImageRequestHandler(cmSampleBuffer: pixelBuffer)
            try? imageRequest.perform([request])
        }
    }
}

struct Prediction {
    let identifier: String
}

