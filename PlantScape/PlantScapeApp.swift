//
//  PlantScapeApp.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 31/05/24.
//

import SwiftUI
import SwiftData

@main
struct PlantScapeApp: App {
    static let subsystem: String = "com.example.PlantScape"
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Plant.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var router = Router()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
