//
//  Untitled.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import CoreLocation
import Combine

final class MockWeatherAPIService: WeatherAPIServiceProtocol {
    // Properties to store mock data

    var mockWeatherResponse: CurrentWeatherResponse?
    var mockForecastResponse: ForecastResponse?
    var mockError: NetworkError?

    /// Delay in seconds before returning data (simulates network latency)
    var delay: TimeInterval = 0.5

    func getCurrentWeather(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<CurrentWeatherResponse, NetworkError> {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockError = mockError
        mockNetworkService.mockResponse = mockWeatherResponse
        mockNetworkService.delay = delay
        return mockNetworkService.request(endpoint: WeatherEndpoint.currentWeather(lat: coordinate.latitude, lon: coordinate.longitude))
    }

    func getForecast(for coordinate: CLLocationCoordinate2D) -> AnyPublisher<ForecastResponse, NetworkError> {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockError = mockError
        mockNetworkService.mockResponse = mockForecastResponse
        mockNetworkService.delay = delay
        return mockNetworkService.request(endpoint: WeatherEndpoint.forecast(lat: coordinate.latitude, lon: coordinate.longitude))
    }
}

