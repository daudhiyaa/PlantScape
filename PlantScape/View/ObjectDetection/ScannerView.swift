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
    @EnvironmentObject var router: Router
    
    @State var isShowingCaptureView = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomLeading) {
                Color.black.ignoresSafeArea()
                if detectorModel.deviceIsAvailable() && !isShowingCaptureView {
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
        .overlay(content: {
//            Button(action: {
//                
//            }, label: {
//                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
//            })
//            NavigationLink(destination: CaptureView(), isActive: $isShowingCaptureView) {}.hidden()
//            NavigationLink(value: Route.scannerView()) {
//                
//            }.navigationDestination(for: Route.self) { route in
//                <#code#>
//            }
        })
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
            ScannedPlantView(scanType: type, isShowingCaptureView: $isShowingCaptureView)
                .onAppear {
                    detectorModel.stopSession()
                }
                .onDisappear {
                    if(isShowingCaptureView == true) {
                        detectorModel.stopScanning()
                        isShowingCaptureView = false
                        router.path.append(NavigationDestination.captureView)
                    } else {
                        detectorModel.restartSession()
                    }
                }
                .interactiveDismissDisabled()
        }
        .environmentObject(detectionResultModel)
        .environmentObject(router)
       
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
