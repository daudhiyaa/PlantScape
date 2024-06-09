//
//  CaptureCompletedView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 09/06/24.
//

import SwiftUI

struct CaptureCompletedView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
            Spacer()
        }.overlay {
            
        }
    }
}

#Preview {
    CaptureCompletedView()
}
