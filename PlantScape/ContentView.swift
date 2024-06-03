//
//  ContentView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 31/05/24.
//

import SwiftUI

struct Plant: Hashable {
    var name: String
    var description: String
    var growingTips: String
    var image: String
    
    init(name: String, description: String, growingTips: String, image: String) {
        self.name = name
        self.description = description
        self.growingTips = growingTips
        self.image = image
    }
}

struct ContentView: View {
    
    @State private var searchText = ""
    
    let plants: [Plant] = [
        Plant(name: "Plant A", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant B", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant C", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant D", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant E", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant F", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant G", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant H", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
        Plant(name: "Plant I", description: "description", growingTips: "Dimandiin dan diberi makan", image: "tree.fill"),
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if plants.isEmpty {
                    VStack(spacing: 20) {
                        Image("image/planticon")
                        VStack(spacing: 6) {
                            Text("Lets discover a new plant")
                                .font(.headline)
                            Text("Scan plants and build your own garden")
                                .font(.callout)
                                .foregroundStyle(Color.gray)
                        }
                        NavigationLink(destination: ScannerView()) {
                            Image(systemName: "camera")
                            Text("Scan")
                        }
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16, content: {
                            ForEach(searchResults, id: \.self) { data in
                                VStack(spacing: 12) {
                                    HStack{ Spacer() }
                                    Image("image/planticon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                    Text(data.name)
                                        .font(.headline)
                                }.padding()
                                    .frame(height: 180)
                                    .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                    )
                            }
                        }).padding(.horizontal, 28)
                            .padding(.top)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .navigationTitle("Plantdex")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ScannerView()) {
                        Image(systemName: "camera")
                    }.foregroundStyle(.green)
                }
            }
        }
        .tint(Color.green)
    }
    
    var searchResults: [Plant] {
        if searchText.isEmpty {
            return plants
        } else {
            return plants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
