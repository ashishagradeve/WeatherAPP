//
//  SearchPlacesView.swift
//  WeatherApp
//
//  Created by Ashish on 01/02/26.
//

import SwiftUI
import MapKit
import SwiftData

struct SearchPlacesView: View {
    @State private var viewModel = SearchPlacesViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            SavedSearchPlacesView() // Pass the VM down
                .navigationTitle("Saved Weather")
                .searchable(
                    text: $viewModel.searchText,
                    isPresented: $viewModel.isSearchPresent,
                    prompt: "Search for a place"
                )
                .searchSuggestions {
                    SearchSuggestionsContent(viewModel: viewModel)
                }
                .overlay {
                    if viewModel.isNoDataFound {
                        ContentUnavailableView("No Locations Found", systemImage: "mappin.slash")
                    }
                }
                .navigationDestination(item: $viewModel.selectedCity) { city in
                    WeatherView(selectedCity: city)
                }
                .listStyle(.plain)
        }
    }
}

#Preview {
    // 1. Set up a memory-only configuration to avoid affecting real app data
    let config = ModelConfiguration(isStoredInMemoryOnly: true)

    // 2. Initialize the container for your SaveLocation model
    let container = try! ModelContainer(for: SaveLocation.self, configurations: config)

    // 3. Optional: Add mock data so you can see the list in the preview canvas
    let sampleLocations = [
        SaveLocation(from: ForecastResponse.sampleData, currentWeatherResponse: CurrentWeatherResponse.sampleData)
    ]

    for location in sampleLocations {
        container.mainContext.insert(location)
    }

    // 4. Return the view to preview, providing the model container
    return NavigationStack {
        SearchPlacesView()
    }
    .modelContainer(container)
}

#Preview("Empty Saved Places") {
    let container = getModelContainer()

    // 4. Return the view to preview, providing the model container
    return NavigationStack {
        SearchPlacesView()
    }
    .modelContainer(container)
}


