//
//  SearchSuggestionsContent.swift
//  WeatherApp
//
//  Created by Ashish on 11/02/26.
//

import SwiftUI
import MapKit

struct SearchSuggestionsContent: View {
    var viewModel: SearchPlacesViewModel

    var body: some View {
        Section {
            NavigationLink(destination: WeatherView()) {
                Text("Your Current Location")
            }
        }

        Section("Suggestions") {
            ForEach(viewModel.completions, id: \.title) { completion in
                SearchablePlacesRow(title: completion.title, subtitle: completion.subtitle) {
                    viewModel.selectCompletion(completion)
                }
            }
        }
    }
}

#Preview {
    // 1. Initialize a mock or real ViewModel
    let viewModel = SearchPlacesViewModel()

    // 2. Set some mock data if you want to see suggestions in the canvas
    // viewModel.searchText = "New York"

    return List {
        SearchSuggestionsContent(viewModel: viewModel)
    }
}
