//
//  WeatherAPIServiceTests.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import Testing
import Foundation
import Combine
import CoreLocation
@testable import WeatherApp // Replace with your actual module name

@Suite("Weather API Service Tests")
@MainActor struct WeatherAPIServiceTests {

    // MARK: - Setup

    /// Helper to create a service with a mock network layer
    @MainActor private func makeSUT() -> (WeatherAPIService, MockNetworkService) {
        let mockNetwork = MockNetworkService()
        let service = WeatherAPIService(networkService: mockNetwork)
        return (service, mockNetwork)
    }

    private let testLocation = CLLocationCoordinate2D(latitude: 19.07, longitude: 72.87)

    // MARK: - Success Tests

    @Test("Successfully fetches current weather")
    func testGetCurrentWeatherSuccess() async throws {
        let (sut, mockNetwork) = makeSUT()

        // Given: A valid mock response
        let mockData = CurrentWeatherResponse.mock(type: .sunny, temp: 30.5)
        mockNetwork.mockResponse = mockData

        // When: Requesting weather
        let publisher = sut.getCurrentWeather(for: testLocation)

        // Then: Use Swift Testing's expectation style with Combine
        let result = try await publisher.asAsync()
        #expect(result.temp == 30.5)
        #expect(result.weatherType == .sunny)
    }

    @Test("Successfully fetches weather forecast")
    func testGetForecastSuccess() async throws {
        let (sut, mockNetwork) = makeSUT()

        // Given: A valid mock forecast
        let mockForecast = ForecastResponse.init(list: [ForecastItem.sampleData], city: City(id: 1, name: "Dubai", coord: .init(lon: 55.2708, lat: 25.2048), country: "UAE"))

        mockNetwork.mockResponse = mockForecast

        // When
        let result = try await sut.getForecast(for: testLocation).asAsync()

        // Then
        #expect(result.city.name == "Dubai")
        #expect(result.list.count > 0)
    }

    // MARK: - Error Tests

    @Test("Propagates network errors correctly")
    func testNetworkErrorPropagation() async {
        let (sut, mockNetwork) = makeSUT()

        // Given: A simulated server error
        mockNetwork.mockError = .serverError(500)

        // Then
        await #expect(throws: NetworkError.self) {
            try await sut.getCurrentWeather(for: testLocation).asAsync()
        }
    }

    @Test("Handles missing data error")
    func testNoDataError() async {
        let (sut, mockNetwork) = makeSUT()

        // Given: No response set in mock
        mockNetwork.mockResponse = nil

        // Then
        await #expect(throws: NetworkError.self) {
            try await sut.getForecast(for: testLocation).asAsync()
        }
    }
}

// MARK: - Combine to Async bridge for Swift Testing
extension AnyPublisher {
    func asAsync() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.first()
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                }, receiveValue: { value in
                    continuation.resume(returning: value)
                })
        }
    }
}

