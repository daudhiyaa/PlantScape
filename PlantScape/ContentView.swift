//
//  ContentView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 31/05/24.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var plants: [Plant]
    
    @StateObject var multipeerSession: MultipeerSession = MultipeerSession(username: UIDevice.current.name)
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Button("Add Plant") {
                    modelContext.insert(dummyPlants[Int.random(in: 0..<dummyPlants.count)])
                }
                Button("Delete All") {
                    for plant in plants {
                        modelContext.delete(plant)
                    }
                }.foregroundColor(.red)
                
                if plants.isEmpty {
                    VStack(spacing: 20) {
                        Image("image/planticon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240)
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
                                NavigationLink(
                                    destination: DetailView(plant: data).environmentObject(multipeerSession)
                                ) {
                                    VStack(spacing: 12) {
                                        HStack{ Spacer() }
                                        Image(data.image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100)
                                        Text(data.name)
                                            .font(.headline)
                                    }
                                    .padding()
                                    .frame(height: 180)
                                    .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor.secondarySystemBackground))
                                    )
                                }
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
        .onChange(of: multipeerSession.receivedPlant) {
            for plant in dummyPlants {
                if(plant.name == multipeerSession.receivedPlant.name) {
                    modelContext.insert(plant)
                }
            }
        }
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
