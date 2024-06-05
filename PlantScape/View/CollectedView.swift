//
//  CollectedView.swift
//  PlantScape
//
//  Created by Daud on 05/06/24.
//

import SwiftUI

struct CollectedView: View {
    var body: some View {
        VStack{
            Image(systemName: "checkmark.seal")
                .resizable()
                .scaledToFit()
                .frame(width: 128)
                .foregroundColor(.green)
            Text("Awesome!")
                .font(.system(size: 36).bold())
            Text("You've collected new plant")
        }
    }
}

#Preview {
    CollectedView()
}
