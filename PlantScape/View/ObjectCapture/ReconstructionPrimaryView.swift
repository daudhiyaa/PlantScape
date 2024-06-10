//
//  ReconstructionPrimaryView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 06/06/24.
//

import Foundation
import RealityKit
import SwiftUI
import SwiftData
import os

@available(iOS 17.0, *)
struct ReconstructionPrimaryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appModel: AppDataModel
    @EnvironmentObject var detectionResultModel: DetectionResultViewModel
    @EnvironmentObject var router: Router
    
    let outputFile: URL
    
    @State private var completed: Bool = false
    @State private var cancelled: Bool = false
    @State var plant: Plant?
    
    @Binding var showReconstructionView: Bool
    
    var body: some View {
        VStack {
            if completed && !cancelled {
                VStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .foregroundStyle(Color.green)
                        
//                    Button {
//                        router.reset()
//                        dismiss()
//                    } label: {
//                        Text("Back to plant dex button")
//                    }.fontWeight(.semibold)
//                        .padding(.horizontal, 24)
//                        .padding(.vertical, 12)
//                        .background(Color.green)
//                        .foregroundStyle(.white)
//                        .cornerRadius(8)

                    Spacer()
                }
                .interactiveDismissDisabled(false)
            } else {
                ReconstructionProgressView(outputFile: outputFile,
                                           completed: $completed,
                                           cancelled: $cancelled,
                                           plant: $plant, showReconstructionView: $showReconstructionView )
                .onAppear(perform: {
                    setupDetails()
                    UIApplication.shared.isIdleTimerDisabled = true
                })
                .onDisappear(perform: {
                    UIApplication.shared.isIdleTimerDisabled = false
                })
                .interactiveDismissDisabled()
            }
        }
        .environmentObject(detectionResultModel)
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

@available(iOS 17.0, *)
struct ReconstructionProgressView: View {
    static let logger = Logger(subsystem: PlantScapeApp.subsystem,
                               category: "ReconstructionProgressView")
    
    let logger = ReconstructionProgressView.logger
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var appModel: AppDataModel
    @EnvironmentObject var detectionResultModel: DetectionResultViewModel
    @EnvironmentObject var router: Router
    
    let outputFile: URL
    @Binding var completed: Bool
    @Binding var cancelled: Bool
    @Binding var plant: Plant?
    @Binding var showReconstructionView: Bool
    
    @State private var progress: Float = 0
    @State private var estimatedRemainingTime: TimeInterval?
    @State private var processingStageDescription: String?
    @State private var pointCloud: PhotogrammetrySession.PointCloud?
    @State private var gotError: Bool = false
    @State private var error: Error?
    @State private var isCancelling: Bool = false
    
    @Query private var plants: [Plant]
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var padding: CGFloat {
        horizontalSizeClass == .regular ? 60.0 : 24.0
    }
    private func isReconstructing() -> Bool {
        return !completed && !gotError && !cancelled
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isReconstructing() {
                HStack {
                    Button(action: {
                        logger.log("Cancelling...")
                        isCancelling = true
                        appModel.photogrammetrySession?.cancel()
                    }, label: {
                        Text(LocalizedString.cancel)
                            .font(.headline)
                            .bold()
                            .padding(30)
                            .foregroundColor(.blue)
                    })
                    .padding(.trailing)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            TitleView()
            
            Spacer()
            
            ProgressBarView(progress: progress,
                            estimatedRemainingTime: estimatedRemainingTime,
                            processingStageDescription: processingStageDescription)
            .padding(padding)
            
            Spacer()
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
        .alert(
            "Failed:  " + (error != nil  ? "\(String(describing: error!))" : ""),
            isPresented: $gotError,
            actions: {
                Button("OK") {
                    logger.log("Calling restart...")
                    appModel.state = .restart
                }
            },
            message: {}
        )
        .task {
            precondition(appModel.state == .reconstructing)
            assert(appModel.photogrammetrySession != nil)
            let session = appModel.photogrammetrySession!
            
            let outputs = UntilProcessingCompleteFilter(input: session.outputs)
            do {
                try session.process(requests: [.modelFile(url: outputFile)])
            } catch {
                logger.error("Processing the session failed!")
            }
            for await output in outputs {
                switch output {
                case .inputComplete:
                    break
                case .requestProgress(let request, fractionComplete: let fractionComplete):
                    if case .modelFile = request {
                        progress = Float(fractionComplete)
                    }
                case .requestProgressInfo(let request, let progressInfo):
                    if case .modelFile = request {
                        estimatedRemainingTime = progressInfo.estimatedRemainingTime
                        processingStageDescription = progressInfo.processingStage?.processingStageString
                    }
                case .requestComplete(let request, _):
                    switch request {
                    case .modelFile(_, _, _):
                        logger.log("RequestComplete: .modelFile")
                    case .modelEntity(_, _), .bounds, .poses, .pointCloud:
                        // Not supported yet
                        break
                    @unknown default:
                        logger.warning("Received an output for an unknown request: \(String(describing: request))")
                    }
                case .requestError(_, let requestError):
                    if !isCancelling {
                        gotError = true
                        error = requestError
                    }
                case .processingComplete:
                    if !gotError {
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                            completed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            router.reset()
                            showReconstructionView = false
                        }
                        appModel.state = .viewing
                    }
                case .processingCancelled:
                    cancelled = true
                    appModel.state = .restart
                case .invalidSample(id: _, reason: _), .skippedSample(id: _), .automaticDownsampling:
                    continue
                case .stitchingIncomplete:
                    break
                @unknown default:
                    logger.warning("Received an unknown output: \(String(describing: output))")
                }
            }
            if (!gotError) {
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                    completed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    router.reset()
                    showReconstructionView = false
                }
                appModel.state = .viewing
                if let p = plant {
                    p.modelUrl = outputFile.absoluteURL
                    if (!plants.contains(p)) {
                        modelContext.insert(p)
                    }
                }
            }
            print(">>>>>>>>>> RECONSTRUCTION TASK EXIT >>>>>>>>>>>>>>>>>")
        }
    }
    
    struct LocalizedString {
        static let cancel = NSLocalizedString(
            "Cancel (Object Reconstruction)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Cancel",
            comment: "Button title to cancel reconstruction")
    }
    
}

extension PhotogrammetrySession.Output.ProcessingStage {
    var processingStageString: String? {
        switch self {
        case .preProcessing:
            return NSLocalizedString(
                "Pre-Processing (Reconstruction)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Pre-Processing…",
                comment: "Feedback message during the object reconstruction phase."
            )
        case .imageAlignment:
            return NSLocalizedString(
                "Aligning Images (Reconstruction)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Aligning Images…",
                comment: "Feedback message during the object reconstruction phase."
            )
        case .pointCloudGeneration:
            return NSLocalizedString(
                "Generating Point Cloud (Reconstruction)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Generating Point Cloud…",
                comment: "Feedback message during the object reconstruction phase."
            )
        case .meshGeneration:
            return NSLocalizedString(
                "Generating Mesh (Reconstruction)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Generating Mesh…",
                comment: "Feedback message during the object reconstruction phase."
            )
        case .textureMapping:
            return NSLocalizedString(
                "Mapping Texture (Reconstruction)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Mapping Texture…",
                comment: "Feedback message during the object reconstruction phase."
            )
        case .optimization:
            return NSLocalizedString(
                "Optimizing (Reconstruction)",
                bundle: AppDataModel.bundleForLocalizedStrings,
                value: "Optimizing…",
                comment: "Feedback message during the object reconstruction phase."
            )
        default:
            return nil
        }
    }
}

private struct TitleView: View {
    var body: some View {
        Text(LocalizedString.processingTitle)
            .font(.largeTitle)
            .fontWeight(.bold)
        
    }
    
    private struct LocalizedString {
        static let processingTitle = NSLocalizedString(
            "Processing title (Object Capture)",
            bundle: AppDataModel.bundleForLocalizedStrings,
            value: "Processing",
            comment: "Title of processing view during processing phase."
        )
    }
}
