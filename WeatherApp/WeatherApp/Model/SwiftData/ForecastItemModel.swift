//
//  ForecastItemModel.swift
//  WeatherApp
//
//  Created by Ashish on 02/02/26.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models for Weather Persistence

@Model
final class ForecastItemModel:Identifiable {
    @Attribute(.unique) var id: UUID
    var dt: TimeInterval
    var temp: Double
    var tempMin: Double
    var tempMax: Double
    private var weatherRaw: String

    var weatherType: WeatherType {
        get { WeatherType(rawValue: weatherRaw) ?? .cloudy }
        set { weatherRaw = newValue.rawValue }
    }

    // Convenience accessor
    var dayName:String {
        return Date(timeIntervalSince1970: dt).formatted(.dateTime.weekday(.wide))
    }

    init(id: UUID = UUID(), dt: TimeInterval, temp: Double, tempMin: Double, tempMax: Double, weatherType: WeatherType) {
        self.id = id
        self.dt = dt
        self.temp = temp
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.weatherRaw = weatherType.rawValue
    }
}

extension ForecastItemModel {
    convenience init(from item: ForecastItem) {
        self.init(
            dt: item.dt,
            temp: item.temp,
            tempMin: item.tempMin,
            tempMax: item.tempMax,
            weatherType: item.weatherType
        )
    }
}

