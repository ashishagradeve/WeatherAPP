//
//  SaveLocation.swift
//  WeatherApp
//
//  Created by Ashish on 02/02/26.
//

import Foundation
import SwiftData

@Model
final class SaveLocation: Identifiable {
    @Attribute(.unique) var id: Int
    var name: String
    var coord: Coordinates
    var country: String

    var fullName: String {
        return "\(name) \(country.count == 0 ? "" : ", \(country)")"
    }

    // To-many relationship to items, delete once Saved Location is deleted
    @Relationship(deleteRule: .cascade) var forecasts: [ForecastItemModel]
    // one-to-one relationship, delete once Saved Location is deleted
    @Relationship(deleteRule: .cascade) var currentWeather: CurrentWeatherModel

    // Additional isFav for makingFavorite
    var isFav: Bool = false

    // show lastupdated in offlineMode
    var lastupdated:TimeInterval {
        return currentWeather.dt
    }

    // Add this to ensure they are always sorted by date
    var sortedForecasts: [ForecastItemModel] {
        return forecasts.sorted { $0.dt < $1.dt }
    }

    init(id: Int, name: String, coord: Coordinates, country: String, isFav: Bool = false, forecasts: [ForecastItemModel] = [], currentWeather: CurrentWeatherModel) {
        self.id = id
        self.name = name
        self.coord = coord
        self.country = country
        self.isFav = isFav
        self.forecasts = forecasts
        self.currentWeather = currentWeather
    }

    convenience init(from forecastResponse: ForecastResponse, currentWeatherResponse: CurrentWeatherResponse) {

        // Extracting the daily summary from the 3-hour list
        let dailyForecasts = forecastResponse.toDailyForecasts()
        self.init(id: forecastResponse.city.id,
                  name: forecastResponse.city.name,
                  coord: forecastResponse.city.coord,
                  country: forecastResponse.city.country,
                  forecasts: dailyForecasts.map { ForecastItemModel(from: $0)},
                  currentWeather: CurrentWeatherModel(from: currentWeatherResponse)
        )
    }
}

extension SaveLocation {
    @MainActor
    static func updateSaveLocation(
        withID id: Int,
        forecastResponse: ForecastResponse,
        currentWeatherResponse: CurrentWeatherResponse,
        context: ModelContext
    ) throws -> SaveLocation? {
        // 1. Fetch the existing model using a Predicate
        let fetchDescriptor = FetchDescriptor<SaveLocation>(
            predicate: #Predicate { $0.id == id }
        )

        do {
            var location = try context.fetch(fetchDescriptor).first

            if let existingLocation = location {
                // 2. Update existing object properties
                existingLocation.name = forecastResponse.city.name
                existingLocation.coord = forecastResponse.city.coord
                existingLocation.country = forecastResponse.city.country

                // 3. Update Relationships
                // Because of .cascade delete rule, we replace the old objects
                // SwiftData will handle the deletion of the old CurrentWeatherModel/ForecastItems
                existingLocation.currentWeather = CurrentWeatherModel(from: currentWeatherResponse)
                existingLocation.forecasts = forecastResponse.toDailyForecasts().map { ForecastItemModel(from: $0) }

            } else {
                // 4. If it doesn't exist, create a new one
                location = SaveLocation(from: forecastResponse, currentWeatherResponse: currentWeatherResponse)
                context.insert(location!)
            }

            return location
        } catch {
            print("Failed to update SaveLocation: \(error.localizedDescription)")
            return nil
        }
    }

}
