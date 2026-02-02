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

    // 1. Fetch all SaveLocation objects, sorted by name
    @Query(sort: \SaveLocation.name) private var locations: [SaveLocation]

    @State private var locationManager = LocationSearchService()
    @State private var selectedCoordinate: Coordinates?
    @State private var selectedLocation: SaveLocation?

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                // SECTION 1: Always show Current Location
                Section {
                    NavigationLink {
                        WeatherView()
                    } label: {
                        Text("Your Current Location")
                    }
                }

                Section {
                    ForEach(locations, id: \.id) { saveLocation in
                        Button {
                            self.selectedLocation = saveLocation
                        } label: {
                            HStack {
                                Text("\(saveLocation.name), \(saveLocation.country)")

                                Spacer()

                                Button {
                                    saveLocation.isFav.toggle()
                                    try? modelContext.save()
                                } label: {
                                    Image(systemName: "heart")
                                        .symbolVariant(saveLocation.isFav ? .fill : .none)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteLocation)
                }
            }
            .overlay {
                if locations.isEmpty {
                    ContentUnavailableView("No Locations", systemImage: "mappin.slash", description: Text("Search for a location to see weather updates."))
                }
            }
            .navigationTitle("Saved Weather")
            .searchable(text: $locationManager.searchText)
            .searchSuggestions {
                // SECTION 1: Always show Current Location
                Section {
                    NavigationLink {
                        WeatherView()
                    } label: {
                        Text("Your Current Location")
                    }
                }

                // SECTION 2: Dynamic Autocomplete Results
                Section("Suggestions") {
                    ForEach(locationManager.completions, id: \.self) { completion in
                        Button {
                            // 1. Fetch the coordinate manually
                            locationManager.getCoordinate(from: completion) { coord in
                                // 2. Setting this triggers the navigation
                                self.selectedCoordinate = coord
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                Text(completion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedCoordinate) { item in
                WeatherView(coordinate: item)
            }
            .navigationDestination(item: $selectedLocation) { selectedLocation in
                WeatherView(lastSaveLocation: selectedLocation)
            }
            .listStyle(.plain) // Removes grouped styling/rounded corner
        }
    }

    // Helper function to delete saved locations
    private func deleteLocation(at offsets: IndexSet) {
        for index in offsets {
            let locationToDelete = locations[index]
            modelContext.delete(locationToDelete)
        }
    }
}
#Preview {
    SearchPlacesView()
}


