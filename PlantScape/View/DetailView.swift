//
//  DetailView.swift
//  PlantScape
//
//  Created by Daud on 03/06/24.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var multipeerSession: MultipeerSession
    @State private var isSheetPresented = false
    
    var plant: Plant
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        Image(plant.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160)
                        Text(plant.name).font(.title3).fontWeight(.bold)
                        GroupBox("Growing Tips") {
                            GroupBox {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .top) {
                                        Image(systemName: "sun.max")
                                            .renderingMode(.original)
                                        Text(plant.growingTips.sun).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack(alignment: .top) {
                                        Image(systemName: "water.waves")
                                            .renderingMode(.original)
                                        Text(plant.growingTips.water).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        GroupBox("Description") {
                            GroupBox {
                                VStack() {
                                    Text(plant.desc).frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        GroupBox("Location") {
                            GroupBox {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Image(systemName: "map")
                                            .renderingMode(.original)
                                        Text(plant.location).frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }.padding(28)
                }
                .padding(.bottom, 60)
            }
            .overlay(
                VStack {
                    Spacer()
                    VStack {
                        NavigationLink(destination: ARViewControllerRepresentable(plantName: plant.name)) {
                            Text("AR View")
                                .frame(maxWidth: .infinity)
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
                }
            )
        }
        .navigationBarTitle("Detail", displayMode: .automatic)
        .navigationBarItems(
            trailing: Button(action: {
                self.isSheetPresented = true
            }) {
                Image(systemName: "square.and.arrow.up").foregroundColor(.green)
            }.popover(isPresented: $isSheetPresented) {
                NavigationView {
                    SharingView(isSheetPresented: $isSheetPresented, plant: plant).environmentObject(multipeerSession)
                }
            }
        )
        .tint(Color.green)
    }
}
