//
//  WeatherContentView.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import SwiftUI

struct WeatherContentView: View {
    let saveLocation: SaveLocation
    @EnvironmentObject var viewModel :WeatherViewModel

    var body: some View {
        let themeColor = Color(hex: saveLocation.currentWeather.weatherType.backgroundThemeColor)

        List {
            // MARK: - Header Section
            Section {
                ZStack {
                    // Dynamic Background Image
                    Image(saveLocation.currentWeather.weatherType.backgroundImageName)
                        .resizable()
                        .scaledToFill() // Changed to fill to better suit a header
                        .frame(height: 250)
                        .clipped()

                    // Main Header Text
                    VStack {
                        Text("\(Int(saveLocation.currentWeather.temp))°")
                            .font(.system(size: 48, weight: .semibold))
                        Text(saveLocation.currentWeather.weatherType.displayName)
                            .font(.system(size: 26, weight: .medium))
                        Text(saveLocation.fullName)
                            .font(.system(size: 22, weight: .medium))

                    }
                    .foregroundColor(.white)
                }
                .weatherRowStyle(backgroundColor: themeColor)
            }

            // Current Day Row
            CurrentTempRow(currentWeather: saveLocation.currentWeather)
                .listRowInsets(EdgeInsets())
                .listRowBackground(themeColor)
                .listRowSeparatorTint(.white)

            // MARK: - Forecast Section
            if saveLocation.forecasts.count > 0 {
                // 5-Day Forecast
                ForEach(saveLocation.sortedForecasts, id: \.dt) { forecastItem in
                    ForecastRow(forecastItem: forecastItem)
                        .weatherRowStyle(backgroundColor: themeColor)
                }
            }
        }
        .listStyle(.plain) // Removes grouped styling/rounded corners
        .background(themeColor)
        .scrollContentBackground(.hidden) // Required to see the themeColor behind the List
        .refreshable {
            viewModel.retry()
        }
    }
}

#Preview("Sunny") {
    let viewModel = WeatherViewModel.mockViewModel()
    let saveLocation = SaveLocation.init(from: ForecastResponse.mock(type: .sunny, temp: 22), currentWeatherResponse: CurrentWeatherResponse.sampleData)
    WeatherContentView(saveLocation: saveLocation)
        .environmentObject(viewModel)
}

#Preview("Cloudy") {
    let viewModel = WeatherViewModel.mockViewModel()
    let saveLocation = SaveLocation.init(from: ForecastResponse.mock(type: .cloudy, temp: 22), currentWeatherResponse: CurrentWeatherResponse.mock(type: .cloudy, temp: 22))
    WeatherContentView(saveLocation: saveLocation)
        .environmentObject(viewModel)
}

#Preview("Rainy") {
    let viewModel = WeatherViewModel.mockViewModel()
    let saveLocation = SaveLocation.init(from: ForecastResponse.mock(type: .rainy, temp: 22), currentWeatherResponse: CurrentWeatherResponse.mock(type: .rainy, temp: 22))
    WeatherContentView(saveLocation: saveLocation)
        .environmentObject(viewModel)
}
