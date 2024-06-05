//
//  ScannedPlantView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 05/06/24.
//

import SwiftUI
import SwiftData

struct ScannedPlantView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var plantdexModel: DetectionResultViewModel
    
    @Query private var plants: [Plant]
    
    let scanType: ScannedItemType
    
    @State private var plant: Plant?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    if let plant = plant {
                        VStack(spacing: 20) {
                            Image(plant.image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160)
                            Text(plant.name).font(.title3).fontWeight(.bold)
                            GroupBox("Growing Tips") {
                                GroupBox {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(plant.growingTips.sun)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(plant.growingTips.water)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            GroupBox("Description") {
                                GroupBox {
                                    VStack(alignment: .leading) {
                                        Text(plant.desc)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            GroupBox("Location") {
                                GroupBox {
                                    VStack(alignment: .leading) {
                                        Text(plant.location)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        .padding(28)
                    } else {
                        Text("No plant data available.")
                            .padding(28)
                    }
                }
                .padding(.bottom, 60)
            }
            .overlay(
                VStack {
                    Spacer()
                    VStack {
                        Button(action: {
                            if(plant != nil && !plants.contains(plant!)) {
                                modelContext.insert(plant!)
                            }
                            dismiss()
                        }, label: {
                            Text("Collect")
                                .frame(maxWidth: .infinity)
                        })
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 28)
                        .padding(.top, 16)
                        .background(Color(UIColor.systemBackground))
                    }
                }
            )
            .navigationBarItems(trailing: (
                Button(action: { dismiss() }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24)
                        .foregroundColor(.gray)
                })
            ))
        }
        .onAppear {
            setupDetails()
        }
    }
    
    private func setupDetails() {
        switch scanType {
        case .produce(let prediction):
            self.plant = plantdexModel.plant(for: prediction.identifier)
        }
    }
}

#Preview {
    ScannedPlantView(scanType: .produce(.init(identifier: "Matahari")))
        .environmentObject(DetectionResultViewModel())
        .preferredColorScheme(.dark)
}
