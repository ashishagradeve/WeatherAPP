//
//  Forecast.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//

import Foundation

// MARK: - Forecast Response
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City

    static var sampleData: ForecastResponse {
        return ForecastResponse.init(list: [ForecastItem.sampleData], city: City(id: 1, name: "Dubai", coord: .init(lon: 55.2708, lat: 25.2048), country: "UAE"))
    }

    /// Helper to create different weather scenarios for testing UI themes
    static func mock(type: WeatherType, temp: Double) -> ForecastResponse {
        let mockForecasts = [
            // Note: We use the init(currentWeather:) provided in your ForecastItem struct
            ForecastItem.mock(addingDay:1, type: type, temp: temp),
            ForecastItem.mock(addingDay:2, type: type, temp: temp),
            ForecastItem.mock(addingDay:3, type: type, temp: temp),
            ForecastItem.mock(addingDay:4, type: type, temp: temp),
            ForecastItem.mock(addingDay:5, type: type, temp: temp)
        ]
        let city = City(id: 1, name: "Dubai", coord: .init(lon: 55.2708, lat: 25.2048), country: "UAE")
        return ForecastResponse(list: mockForecasts, city: city)
    }
}

// MARK: - Forecast Item
struct ForecastItem: Codable {
    let dt: TimeInterval

    // Properties flattened from MainWeatherData
    let temp: Double
    let tempMin: Double
    let tempMax: Double

    // Property flattened from weather[0] and converted to enum
    let weatherType: WeatherType

    enum CodingKeys: String, CodingKey {
        case dt, main, weather
    }

    enum MainKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }

    enum WeatherKeys: String, CodingKey {
        case main
    }

    init(currentWeather:CurrentWeatherResponse) {
        dt = currentWeather.dt
        weatherType = currentWeather.weatherType
        temp = currentWeather.temp
        tempMin = currentWeather.tempMin
        tempMax = currentWeather.tempMax
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 1. Decode root date
        dt = try container.decode(TimeInterval.self, forKey: .dt)

        // 2. Dig into "main" container
        let mainContainer = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        temp = try mainContainer.decode(Double.self, forKey: .temp)
        tempMin = try mainContainer.decode(Double.self, forKey: .tempMin)
        tempMax = try mainContainer.decode(Double.self, forKey: .tempMax)

        // 3. Dig into the first element of "weather" array
        var weatherArrayContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        if !weatherArrayContainer.isAtEnd {
            let firstWeatherContainer = try weatherArrayContainer.nestedContainer(keyedBy: WeatherKeys.self)
            // Decodes the string "main" into your WeatherType enum
            weatherType = try firstWeatherContainer.decode(WeatherType.self, forKey: .main)
        } else {
            weatherType = .cloudy
        }
    }

    // Provide encoding to mirror our custom decoding that flattened fields
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dt, forKey: .dt)

        // Recreate the nested "main" container
        var mainContainer = container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        try mainContainer.encode(temp, forKey: .temp)
        try mainContainer.encode(tempMin, forKey: .tempMin)
        try mainContainer.encode(tempMax, forKey: .tempMax)

        // Recreate the nested "weather" array with one element having the "main" string
        var weatherArray = container.nestedUnkeyedContainer(forKey: .weather)
        var firstWeather = weatherArray.nestedContainer(keyedBy: WeatherKeys.self)
        try firstWeather.encode(weatherType, forKey: .main)
    }
}

// MARK: - getting a response for every 3 hour, it is converted to daily forcast
extension ForecastResponse {
    func toDailyForecasts() -> [ForecastItem] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: list) { item -> Date in
            let date = Date(timeIntervalSince1970: item.dt)
            return calendar.startOfDay(for: date)
        }

        let sortedDays = grouped.keys.sorted()
        var forecasts = sortedDays.prefix(6).compactMap { day -> ForecastItem? in
            guard let items = grouped[day],
                  let noonItem = items.min(by: { abs($0.dt - (day.timeIntervalSince1970 + 43200)) < abs($1.dt - (day.timeIntervalSince1970 + 43200)) })
            else { return nil }
            return noonItem
        }

        // 2. Filter out the first day if it's today
        forecasts = forecasts.first.map { Calendar.current.isDate(Date(timeIntervalSince1970: $0.dt), inSameDayAs: Date()) } == true
            ? Array(forecasts.dropFirst()) : forecasts

        return forecasts
    }
}

// MARK: - Sample
extension ForecastItem {
    static var sampleData: ForecastItem {
        let json = """
        {
            "dt": \(Int(Date().timeIntervalSince1970)),
            "main": {
                "temp": 25.5,
                "temp_min": 22.0,
                "temp_max": 28.0
            },
            "weather": [
                { "main": "Rain" }
            ]
        }
        """.data(using: .utf8)!

        return try! JSONDecoder().decode(ForecastItem.self, from: json)
    }

    /// Helper to create different ForecastItem scenarios for testing UI themes
    static func mock(addingDay:Int = 1, type: WeatherType, temp: Double) -> ForecastItem {

        let newDate = Calendar.current.date(byAdding: .day, value: addingDay, to: Date()) ?? Date()
        let json = """
        {
            "dt": \(Int(newDate.timeIntervalSince1970)),
            "weather": [{"main": "\(type.rawValue)"}],
            "main": {
                "temp": \(temp),
                "temp_min": \(temp - 2),
                "temp_max": \(temp + 2)
            },
            "dt": \(Int(Date().timeIntervalSince1970)),
        }
        """.data(using: .utf8)!

        return try! JSONDecoder().decode(ForecastItem.self, from: json)
    }
}
