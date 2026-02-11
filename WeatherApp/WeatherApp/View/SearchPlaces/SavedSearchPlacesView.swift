//
//  SavedSearchPlacesView.swift
//  WeatherApp
//
//  Created by Ashish on 08/02/26.
//

import SwiftUI
import SwiftData

struct SavedSearchPlacesView: View {
    @Query(sort: [SortDescriptor(\SaveLocation.name, comparator: .localizedStandard)]) private var locations: [SaveLocation]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedLocation: SaveLocation?

    var body: some View {
        // This body now only re-evaluates if 'locations' (SwiftData) changes
        // or if 'selectedLocation' changes.
        List {
            Section {
                NavigationLink(destination: WeatherView()) {
                    Text("Your Current Location")
                }
            }

            if !locations.isEmpty {
                Section("Saved Locations") {
                    ForEach(locations) { location in
                        // Internal optimization: Row updates are scoped to the Row view
                        SavedPlacesRow(
                            isFav: Binding(
                                get: { location.isFav },
                                set: { location.isFav = $0
                                    try? modelContext.save()
                                }
                            ),
                            fullName: location.fullName
                        ) {
                            self.selectedLocation = location
                        }
                    }
                    .onDelete(perform: deleteLocation)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if locations.isEmpty {
                ContentUnavailableView {
                    Label("No Locations Found", systemImage: "mappin.slash")
                } description: {
                    Text("Search the city to add it to the list")
                }
            }
        }
        .navigationDestination(item: $selectedLocation) { location in
            WeatherView(lastSaveLocation: location)
        }
    }

    private func deleteLocation(at offsets: IndexSet) {
        // Resolve concrete indices first to avoid mutation issues while iterating
        let indices = Array(offsets)
        for index in indices {
            let location = locations[index]
            modelContext.delete(location)
        }
        // Persist deletions explicitly to avoid ambiguity in previews
        try? modelContext.save()
    }
}

#Preview("Saved Places") {
    let container = getModelContainer()
    // 3. Optional: Add mock data so you can see the list in the preview canvas
    let sampleLocations = [
        SaveLocation(from: ForecastResponse.sampleData, currentWeatherResponse: CurrentWeatherResponse.sampleData)
    ]

    for location in sampleLocations {
        container.mainContext.insert(location)
    }

    // 4. Return the view to preview, providing the model container
    return NavigationStack {
        SavedSearchPlacesView()
    }
    .modelContainer(container)
}

#Preview("Empty Saved Places") {
    let container = getModelContainer()

    // 4. Return the view to preview, providing the model container
    return NavigationStack {
        SavedSearchPlacesView()
    }
    .modelContainer(container)
}


func getModelContainer() -> ModelContainer {
    // 1. Set up a memory-only configuration to avoid affecting real app data
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    // 2. Initialize the container for your SaveLocation model
    return try! ModelContainer(for: SaveLocation.self, configurations: config)
}
