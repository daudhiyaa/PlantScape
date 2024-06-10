//
//  ContentView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 31/05/24.
//
import SwiftUI
import SwiftData

enum NavigationDestination: Hashable {
    case scannerView
    case captureView
    case detailView(Plant)
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var router: Router
    @Query private var plants: [Plant]
    
    @StateObject private var detectionResultModel = DetectionResultViewModel()
    @StateObject var multipeerSession: MultipeerSession = MultipeerSession(username: UIDevice.current.name)
    
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                if plants.isEmpty {
                    emptyStateView
                } else {
                    plantGridView
                }
            }
            .alert("Received an invite from \(multipeerSession.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $multipeerSession.recvdInvite) {
                inviteAlertButtons
            }
            .background(Color(UIColor.systemBackground))
            .navigationDestination(for: NavigationDestination.self, destination: destinationView)
            .navigationTitle("Plantdex")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: NavigationDestination.scannerView) {
                        Image(systemName: "camera")
                    }.foregroundStyle(.green)
                }
            }
        }
        .environmentObject(detectionResultModel)
        .environmentObject(router)
        .onChange(of: multipeerSession.receivedPlant) {
            insertReceivedPlant($0)
        }
        .tint(Color.green)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image("image/planticon")
                .resizable()
                .scaledToFit()
                .frame(width: 240)
            VStack(spacing: 6) {
                Text("Lets discover a new plant")
                    .font(.title3).fontWeight(.semibold)
                Text("Scan plants and build your own garden")
                    .font(.body)
                    .foregroundStyle(Color.gray)
            }
            NavigationLink(value: NavigationDestination.scannerView) {
                Image(systemName: "camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                Text("Scan")
            }
            .fontWeight(.semibold)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.green)
            .foregroundStyle(.white)
            .cornerRadius(8)
        }.padding(28)
    }
    
    private var plantGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16, content: {
                ForEach(searchResults, id: \.self) { data in
                    NavigationLink(value: NavigationDestination.detailView(data)) {
                        plantItemView(data)
                    }
                }
            }).padding(.horizontal, 28)
              .padding(.top)
        }
    }
    
    private func plantItemView(_ data: Plant) -> some View {
        VStack(spacing: 12) {
            HStack{ Spacer() }
            Image(data.image)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
            Text(data.name)
                .font(.headline)
                .foregroundStyle(Color.text)
        }
        .padding()
        .frame(height: 180)
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private var inviteAlertButtons: some View {
        Group {
            Button("Accept invite") {
                if (multipeerSession.invitationHandler != nil) {
                    multipeerSession.invitationHandler!(true, multipeerSession.session)
                }
            }
            Button("Reject invite") {
                if (multipeerSession.invitationHandler != nil) {
                    multipeerSession.invitationHandler!(false, nil)
                }
            }
        }
    }
    
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .scannerView:
            return AnyView(ScannerView())
        case .captureView:
            return AnyView(CaptureView())
        case .detailView(let plant):
            return AnyView(DetailView(plant: plant).environmentObject(multipeerSession))
        }
    }
    
    private var searchResults: [Plant] {
        if searchText.isEmpty {
            return plants
        } else {
            return plants.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private func insertReceivedPlant(_ receivedPlant: Plant) {
        for plant in plantDataset {
            if plant.name == receivedPlant.name {
                modelContext.insert(plant)
            }
        }
    }
}

#Preview {
    ContentView().preferredColorScheme(.dark)
}
