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

    @State private var locationManager = LocationSearchService()
    @State private var selectedCity: City?
    @State private var isSearchPresent: Bool = false

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            SavedSearchPlacesView()
                .navigationTitle("Saved Weather")
                .searchable( text: $locationManager.searchText, isPresented: $isSearchPresent, placement: SearchFieldPlacement.automatic, prompt: "Search for a place")
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
                        ForEach(locationManager.completions, id: \.title) { completion in
                            Button {
                                getCoordinate(completion: completion)
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
                }.overlay {
                    if locationManager.isNoDataFound == true && locationManager.completions.isEmpty {
                        ContentUnavailableView("No Locations Found", systemImage: "mappin.slash", description: Text(""))
                    }
                }
                .navigationDestination(item: $selectedCity) { item in
                    WeatherView(selectedCity: item)
                }
                .listStyle(.plain) // Removes grouped styling/rounded corner
        }
    }

    private func getCoordinate(completion: MKLocalSearchCompletion) {
        // 1. Fetch the coordinate manually
        locationManager.getCoordinate(from: completion) { coord in
            // 2. Setting this triggers the navigation
            if let coord = coord {
                self.isSearchPresent = false
                self.locationManager.searchText = ""
                self.selectedCity = City(id: 1, name: completion.title, coord: coord, country:completion.subtitle)
            }
        }
    }
}


#Preview {
    SearchPlacesView()
}





