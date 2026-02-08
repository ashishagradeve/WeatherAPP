//
//  SavedSearchPlacesView.swift
//  WeatherApp
//
//  Created by Ashish on 08/02/26.
//

import SwiftUI
import SwiftData

struct SavedSearchPlacesView: View {
    // 1. Fetch all SaveLocation objects, sorted by name
    @Query( sort: \SaveLocation.name) private var locations: [SaveLocation]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedLocation: SaveLocation?

    var body: some View {
        List {
            // SECTION 1: Always show Current Location
            Section {
                NavigationLink {
                    WeatherView()
                } label: {
                    Text("Your Current Location")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if locations.count > 0 {
                Section("Saved Locations") {
                    ForEach(locations, id: \.id) { saveLocation in
                        Button {
                            self.selectedLocation = saveLocation
                        } label: {
                            HStack {
                                Text(saveLocation.fullName)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Button {
                                    saveLocation.isFav.toggle()
                                    try? modelContext.save()
                                } label: {
                                    Image(systemName: "heart")
                                        .symbolVariant(saveLocation.isFav ? .fill : .none)
                                }.frame(alignment: .trailing)
                            }
                        }
                    }
                    .onDelete(perform: deleteLocation)
                }
            }
        }.overlay {
            if locations.isEmpty {
                ContentUnavailableView("No Locations", systemImage: "mappin.slash", description: Text("Search for a location to see weather updates."))
            }
        }.navigationDestination(item: $selectedLocation) { selectedLocation in
            let _ = Self._printChanges()
            WeatherView(lastSaveLocation: selectedLocation)
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
    SavedSearchPlacesView()
}
