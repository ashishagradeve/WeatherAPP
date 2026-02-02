//
//  Weather.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//

import Foundation

// MARK: - Current Weather Response

struct CurrentWeatherResponse: Codable {
    let coord: Coordinates
    let dt: TimeInterval

    // Flattened from MainWeatherData
    let temp: Double
    let tempMin: Double
    let tempMax: Double

    // Flattened from weather[0] and converted to Enum
    let weatherType: WeatherType

    enum CodingKeys: String, CodingKey {
        case coord, dt, name, weather, main
    }

    enum MainKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }

    enum WeatherKeys: String, CodingKey {
        case main
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // 1. Root properties
        coord = try container.decode(Coordinates.self, forKey: .coord)
        dt = try container.decode(TimeInterval.self, forKey: .dt)

        // 2. Main nested properties
        let mainContainer = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        tempMin = try mainContainer.decode(Double.self, forKey: .tempMin)
        tempMax = try mainContainer.decode(Double.self, forKey: .tempMax)
        temp = try mainContainer.decode(Double.self, forKey: .temp)

        // 3. Extract 'main' and convert to WeatherType
        var weatherArrayContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        if !weatherArrayContainer.isAtEnd {
            let firstWeatherContainer = try weatherArrayContainer.nestedContainer(keyedBy: WeatherKeys.self)
            // This uses the custom init in WeatherType to map the string
            weatherType = try firstWeatherContainer.decode(WeatherType.self, forKey: .main)
        } else {
            weatherType = .cloudy
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // 1. Root properties
        try container.encode(coord, forKey: .coord)
        try container.encode(dt, forKey: .dt)

        // 2. Main nested properties
        var mainContainer = container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        try mainContainer.encode(temp, forKey: .temp)
        try mainContainer.encode(tempMin, forKey: .tempMin)
        try mainContainer.encode(tempMax, forKey: .tempMax)

        // 3. Weather array with first element's `main`
        var weatherArray = container.nestedUnkeyedContainer(forKey: .weather)
        var firstWeather = weatherArray.nestedContainer(keyedBy: WeatherKeys.self)
        try firstWeather.encode(weatherType, forKey: .main)
    }
}

// MARK: - Sample

extension CurrentWeatherResponse {
    /// Mock data for SwiftUI Previews and Unit Testing
    static var sampleData: CurrentWeatherResponse {
        let json = """
        {
            "coord": {
                "lon": 72.8777,
                "lat": 19.0760
            },
            "weather": [
                {
                    "main": "Clear"
                }
            ],
            "main": {
                "temp": 28.5,
                "temp_min": 26.0,
                "temp_max": 31.0
            },
            "dt": \(Int(Date().timeIntervalSince1970)),
        }
        """.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(CurrentWeatherResponse.self, from: json)
        } catch {
            fatalError("Failed to decode sample CurrentWeatherResponse: \(error)")
        }
    }

    /// Helper to create different weather scenarios for testing UI themes
    static func mock(type: WeatherType, temp: Double) -> CurrentWeatherResponse {
        let json = """
        {
            "coord": {"lon": -122.41, "lat": 37.77},
            "weather": [{"main": "\(type.rawValue)"}],
            "main": {
                "temp": \(temp),
                "temp_min": \(temp - 2),
                "temp_max": \(temp + 2)
            },
            "dt": \(Int(Date().timeIntervalSince1970)),
        }
        """.data(using: .utf8)!

        return try! JSONDecoder().decode(CurrentWeatherResponse.self, from: json)
    }
}
