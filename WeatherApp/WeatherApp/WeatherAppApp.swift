//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//

import SwiftUI
import SwiftData

@main
struct WeatherAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SaveLocation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SearchPlacesView()
        }
        .modelContainer(sharedModelContainer)
    }
}
