//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import SwiftUI

struct WeatherView: View {

    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = WeatherViewModel()

    var coordinate: Coordinates? // Regular property, not @Binding
    var lastSaveLocation: SaveLocation? // Regular property, not @Binding

    var body: some View {
        let themeColor = Color(hex: viewModel.saveLocation?.currentWeather.weatherType.backgroundThemeColor ?? "000000")

        ZStack {
            // SCENARIO 1: SUCCESS - Data is loaded
            if let saveLocation = viewModel.saveLocation {
                WeatherContentView(saveLocation: saveLocation)
            }
            // SCENARIO 2: ERROR - Something went wrong
            else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    viewModel.retry()
                }
            // SCENARIO 3: Show toast, last updated
            }
            // SCENARIO 3: LOADING - Initial state
            else {
                LoadingView()
            } 
        }.background(themeColor)
        .task {
            viewModel.modelContext = modelContext
            viewModel.coordinates = coordinate
            viewModel.lastSaveLocation = lastSaveLocation
            //  coordinates for initial load
            viewModel.retry()
        }.toast(isShowing: $viewModel.isShowToast, message: viewModel.toastMessage ?? "---")
        .environmentObject(viewModel)
    }
}

#Preview {
    let viewModel = WeatherViewModel.mockViewModel()
    WeatherView()
        .environmentObject(viewModel)
}

