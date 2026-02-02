//
//  WeatherType.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//

// MARK: - Weather Type Enum

enum WeatherType: String, Codable {
    case cloudy = "Clouds"
    case rainy = "Rain"
    case sunny = "Clear"

    var backgroundImageName: String {
        switch self {
        case .sunny: return "forest_sunny"
        case .cloudy: return "forest_cloudy"
        case .rainy: return "forest_rainy"
        }
    }

    var iconImage: String {
        switch self {
        case .sunny: return "clear"
        case .cloudy: return "partlysunny"
        case .rainy: return "rain"
        }
    }

    var displayName: String {
        switch self {
        case .sunny: return "SUNNY"
        case .cloudy: return "CLOUDY"
        case .rainy: return "RAINY"
        }
    }

    var backgroundThemeColor: String {
        switch self {
        case .sunny: return "47AB2F"
        case .cloudy: return "54717A"
        case .rainy: return "57575D"
        }
    }

    // Optional: If the API sends "Rain" but you want to handle "rainy"
    // as a fallback for lowercase matches.
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let status = try container.decode(String.self)
        switch status.lowercased() {
        case "clear":
            self = .sunny
        case "clouds":
            self = .cloudy
        case "rain", "drizzle", "thunderstorm":
            self = .rainy
        default:
            self = .cloudy
        }
    }
}
