//
//  CaptureView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 06/06/24.
//

import SwiftUI
import RealityKit
import os

@available(iOS 17.0, *)
struct CaptureView: View {
    static let logger = Logger(subsystem: PlantScapeApp.subsystem,
                                category: "ContentView")
    
    @EnvironmentObject var detectionResultModel: DetectionResultViewModel
    @EnvironmentObject var router: Router

    @StateObject var appModel: AppDataModel = AppDataModel.instance
    
    @State private var showReconstructionView: Bool = false
    @State private var showErrorAlert: Bool = false
    @State var plant: Plant?
    @State private var defaultFileName = "model-mobile"
    
    private var showProgressView: Bool {
        appModel.state == .completed || appModel.state == .restart || appModel.state == .ready
    }

    var body: some View {
        VStack {
            if appModel.state == .capturing {
                if let session = appModel.objectCaptureSession {
                    CapturePrimaryView(session: session)
                }
            } else if showProgressView {
                CircularProgressView()
            }
        }
        .onChange(of: appModel.state) { _, newState in
            if newState == .failed {
                showErrorAlert = true
                showReconstructionView = false
            } else {
                showErrorAlert = false
                showReconstructionView = newState == .reconstructing || newState == .viewing
            }
        }
        .sheet(isPresented: $showReconstructionView) {
            if let folderManager = appModel.scanFolderManager {
                ReconstructionPrimaryView(outputFile: folderManager.modelsFolder.appendingPathComponent("\(plant?.name.split(separator: " ").joined(separator: "-") ?? defaultFileName).usdz"))
            }
        }
        .alert(
            "Failed:  " + (appModel.error != nil  ? "\(String(describing: appModel.error!))" : ""),
            isPresented: $showErrorAlert,
            actions: {
                Button("OK") {
                    CaptureView.logger.log("Calling restart...")
                    appModel.state = .restart
                }
            },
            message: {}
        )
        .onAppear {
            setupDetails()
        }
        .environmentObject(appModel)
        .environmentObject(detectionResultModel)
        .environmentObject(router)
    }
    
    private func setupDetails() {
        switch detectionResultModel.scannedPlant {
        case .produce(let prediction):
            self.plant = detectionResultModel.plant(for: prediction.identifier)
        default :
            break
        }
    }
}

private struct CircularProgressView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .light ? .black : .white))
                Spacer()
            }
            Spacer()
        }
    }
}

#Preview {
    CaptureView()
}
