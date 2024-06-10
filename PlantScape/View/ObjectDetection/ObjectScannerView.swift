//
//  ObjectScannerView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import SwiftUI
import CoreML
import AVFoundation
import Foundation

struct ObjectScannerView: View {
    
    @ObservedObject var detectorModel: ObjectDetectorViewModel
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CameraView(detectorModel: detectorModel)
            VStack {
                Spacer()
                    .frame(height: 200)
                Text("Place plant within view")
                    .font(.headline)
                if detectorModel.didDetectObject {
                    Text("Detecting plant...")
                        .font(.headline)
                        .padding(.top, 7)
                }
                Spacer()
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.white)
        }
    }
}

fileprivate struct CameraView: UIViewRepresentable {
    
    @ObservedObject var detectorModel: ObjectDetectorViewModel
    
    func makeUIView(context: Context) -> UIView {
        return context.coordinator.view
    }
    
    func makeCoordinator() -> ObjectDetectorViewModel {
        detectorModel
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    typealias UIViewType = UIView
}

#Preview {
    ObjectScannerView(detectorModel: ObjectDetectorViewModel())
}
