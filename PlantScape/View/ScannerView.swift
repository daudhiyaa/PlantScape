//
//  ScannerView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 31/05/24.
//

import SwiftUI

struct ResultSheet: View {
    @Environment(\.dismiss) var dismiss
    
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
                        .background(Color.white)
                    }.background(.red)
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
        .tint(Color.green)
    }
}

struct ScannerView: View {
    @State var isShowingResult: Bool = false
    var body: some View {
        NavigationView {
            Button(action: {
                isShowingResult.toggle()
            }, label: {
                Text("Result Modal")
            }).fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.green)
                .foregroundStyle(.white)
                .cornerRadius(8)
                .sheet(isPresented: $isShowingResult, content: {
                    ResultSheet()
                })
        }.tint(Color.green)
            .accentColor(Color.green)
    }
}

#Preview {
    ScannerView()
}
