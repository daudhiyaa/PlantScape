//
//  RequestCameraView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import SwiftUI

struct CameraPermissionView: View {
    
    @ObservedObject var dectectorModel: ObjectDetectorViewModel
    
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                    .frame(height: 200)
                
                Image(systemName: "camera.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 75)
                
                Spacer()
                
                    .frame(height: 20)
                Text("Camera Permission Request")
                    .font(.system(size: 28).bold())
                Text("In order to get the most out of Plantscape, we require the use of your device's camera.")
                    .font(.system(size: 18))
                
                Spacer()
                
                Button {
                    dismiss()
                    dectectorModel.requestAccess()
                } label: {
                    Text("Request")
                }
                .fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .foregroundColor(Color.white)
            .padding(28)
            .multilineTextAlignment(.center)
        }
        .interactiveDismissDisabled()
    }
}

struct CPV_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionView(dectectorModel: ObjectDetectorViewModel()).preferredColorScheme(.light)
    }
}
