//
//  SearchPlacesViewModel.swift
//  WeatherApp
//
//  Created by Ashish on 11/02/26.
//

import SwiftUI
import SwiftData
import MapKit

@Observable
class SearchPlacesViewModel {
    // Search Properties
    var searchText: String = "" {
        didSet {
            locationManager.searchText = searchText
        }
    }
    var isSearchPresent: Bool = false
    var selectedCity: City?

    // Dependencies
    private let locationManager = LocationSearchService()

    // Derived Search Results
    var completions: [MKLocalSearchCompletion] {
        locationManager.completions
    }

    var isNoDataFound: Bool {
        print("locationManager.isNoDataFound \(locationManager.isNoDataFound)")
        return locationManager.isNoDataFound
    }

    // MARK: - Actions

    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        locationManager.getCoordinate(from: completion) { [weak self] coord in
            guard let self = self, let coord = coord else { return }

            self.isSearchPresent = false
            self.searchText = ""
            self.selectedCity = City(
                id: Int.random(in: 0...1000), // Ensure unique ID
                name: completion.title,
                coord: coord,
                country: completion.subtitle
            )
        }
    }

    func toggleFavorite(for location: SaveLocation, context: ModelContext) {
        location.isFav.toggle()
        // SwiftData usually autosaves, but explicit saves should be handled carefully
        do {
            try context.save()
        } catch {
            print("Failed to save favorite status: \(error)")
        }
    }

    func deleteLocation(_ location: SaveLocation, context: ModelContext) {
        context.delete(location)
    }
}
