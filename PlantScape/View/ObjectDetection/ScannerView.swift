//
//  ScannerView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 31/05/24.
//

import SwiftUI

struct ScannerView: View {
    @StateObject private var detectorModel = ObjectDetectorViewModel()
    @EnvironmentObject var detectionResultModel: DetectionResultViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomLeading) {
                Color.black.ignoresSafeArea()
                if detectorModel.deviceIsAvailable() {
                    ObjectScannerView(detectorModel: detectorModel)
                        .ignoresSafeArea()
                }
                ZStack {
                    LinearGradient(colors: [.black.opacity(0.15), .clear, .black.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    VStack {
                        header
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            detectorModel.setObjectDelegate(detectionResultModel)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                self.detectorModel.checkAuthStatus()
            }
        }
        .sheet(isPresented: $detectorModel.isShowingAuthRequestView) {
            CameraPermissionView(dectectorModel: detectorModel)
        }
        .sheet(item: $detectionResultModel.scannedItemView) { type in
            ScannedPlantView(scanType: type)
                .onAppear {
                    detectorModel.stopSession()
                }
                .onDisappear {
                    detectorModel.restartSession()
                }
                .interactiveDismissDisabled()
        }
        .environmentObject(detectionResultModel)
    }
    
    var header: some View {
        VStack {
            Button(action: {
                detectorModel.toggleTorch()
            }, label: {
                Image(systemName: detectorModel.torchActive ? "sun.min.fill" : "sun.max.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            })
        }.shadow(radius: 1)
            .foregroundColor(.white)
            .padding()
    }
}

#Preview {
    ScannerView()
        .environmentObject(DetectionResultViewModel())
}