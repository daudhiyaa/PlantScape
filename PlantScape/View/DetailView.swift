//
//  DetailView.swift
//  PlantScape
//
//  Created by Daud on 03/06/24.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        Image("image/planticon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160)
                        Text("Plant A").font(.title3).fontWeight(.bold)
                        GroupBox("Growing Tips") {
                            GroupBox {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .top) {
                                        Image(systemName: "sun.max")
                                            .renderingMode(.original)
                                        Text("Full sun").frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack(alignment: .top) {
                                        Image(systemName: "water.waves")
                                            .renderingMode(.original)
                                        Text("Infrequent watering").frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                        GroupBox("Description") {
                            GroupBox {
                                VStack(alignment: .leading) {
                                    Text("This is plant A that grows primarily in West part of the earth.")
                                }
                            }
                        }
                        GroupBox("Location") {
                            GroupBox {
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        Image(systemName: "map")
                                            .renderingMode(.original)
                                        Text("Apple Developer Academy").frame(maxWidth: .infinity, alignment: .leading)
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
                        Button(action: {}, label: {
                            Text("AR View")
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
                        .background(Color.white)
                    }.background(.red)
                }
            )
        }
        .navigationBarTitle("Detail", displayMode: .automatic)
        .navigationBarItems(
            trailing: Button(action: {
                
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        )
        .tint(Color.green)
    }
}

#Preview {
    DetailView()
}
