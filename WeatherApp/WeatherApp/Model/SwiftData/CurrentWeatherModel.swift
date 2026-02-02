//
//  Untitled.swift
//  WeatherApp
//
//  Created by Ashish on 02/02/26.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models for Weather Persistence

@Model
final class CurrentWeatherModel {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var dt: TimeInterval
    var temp: Double
    var tempMin: Double
    var tempMax: Double
    private var weatherRaw: String

    // Bridge to your existing WeatherType enum using its rawValue
    var weatherType: WeatherType {
        get { WeatherType(rawValue: weatherRaw) ?? .cloudy }
        set { weatherRaw = newValue.rawValue }
    }

    init(id: UUID = UUID(), latitude: Double, longitude: Double, dt: TimeInterval, temp: Double, tempMin: Double, tempMax: Double, weatherType: WeatherType) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.dt = dt
        self.temp = temp
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.weatherRaw = weatherType.rawValue
    }
}

extension CurrentWeatherModel {
    convenience init(from response: CurrentWeatherResponse) {
        self.init(
            latitude: response.coord.lat,
            longitude: response.coord.lon,
            dt: response.dt,
            temp: response.temp,
            tempMin: response.tempMin,
            tempMax: response.tempMax,
            weatherType: response.weatherType
        )
    }
}
