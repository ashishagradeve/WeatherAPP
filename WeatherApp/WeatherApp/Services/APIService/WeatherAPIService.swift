//
//  WeatherAPIService.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//

import Foundation
import Combine
import CoreLocation

// MARK: - Weather API Endpoints
enum WeatherEndpoint: Endpoint {
    case currentWeather(lat: Double, lon: Double)
    case forecast(lat: Double, lon: Double)

    var baseURL: String {
        "https://api.openweathermap.org/data/2.5"
    }

    var path: String {
        switch self {
        case .currentWeather:
            return "/weather"
        case .forecast:
            return "/forecast"
        }
    }

    var queryItems: [URLQueryItem] {
        let apiKey = APIKeyProvider.openWeather

        switch self {
        case .currentWeather(let lat, let lon), .forecast(let lat, let lon):
            return [
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lon", value: String(lon)),
                URLQueryItem(name: "appid", value: apiKey),
                URLQueryItem(name: "units", value: "metric")
            ]
        }
    }

    var method: HTTPMethod {
        .get
    }
}

// MARK: - Weather API Service Protocol
protocol WeatherAPIServiceProtocol {
    func getCurrentWeather(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentWeatherResponse, NetworkError>
    func getForecast(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<ForecastResponse, NetworkError>
}

// MARK: - Weather API Service Implementation
final class WeatherAPIService: WeatherAPIServiceProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }

    func getCurrentWeather(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentWeatherResponse, NetworkError> {

        let endpoint = WeatherEndpoint.currentWeather(
            lat: coordinate.latitude,
            lon: coordinate.longitude
        )
        return networkService.request(endpoint: endpoint)
    }

    func getForecast(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<ForecastResponse, NetworkError> {
        let endpoint = WeatherEndpoint.forecast(
            lat: coordinate.latitude,
            lon: coordinate.longitude
        )
        return networkService.request(endpoint: endpoint)
    }
}

