//
//  File.swift
//  WeatherViewModel
//
//  Created by Ashish on 30/01/26.
//

import SwiftUI
import Combine
import CoreLocation
import SwiftData

class WeatherViewModel: ObservableObject {
    @Published var saveLocation: SaveLocation?
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var toastMessage : String?
    @Published var isShowToast: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let weatherService: WeatherAPIServiceProtocol
    private let locationService: LocationServiceProtocol

    // coodinates of search location
    var coordinates: Coordinates?
    var lastSaveLocation: SaveLocation?

    // main model context
    var modelContext: ModelContext?

    init(weatherService: WeatherAPIServiceProtocol = WeatherAPIService(), locationService: LocationServiceProtocol = LocationService(), modelContext: ModelContext? = nil) {
        self.weatherService = weatherService
        self.locationService = locationService
        self.modelContext = modelContext
    }

    func fetchWeather(for coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil

        // Zip both current weather and forecast requests together
        Publishers.Zip(
            weatherService.getCurrentWeather(for: coordinate),
            weatherService.getForecast(for: coordinate)
        )
        .sink { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.handleNetworkError(error)
            }
        } receiveValue: { [weak self] current, forecast in
            if let self = self, let context = self.modelContext {
                _ = try? SaveLocation.updateSaveLocation(withID: forecast.city.id, forecastResponse: forecast, currentWeatherResponse: current, context: context)
            }
            self?.saveLocation = SaveLocation(from: forecast, currentWeatherResponse: current)
        }
        .store(in: &cancellables)
    }

    func handleNetworkError(_ error: Error) {
        print("Error fetching weather: \(error)")
        if let saveLocation = saveLocation {
            showToast(dt: saveLocation.lastupdated)
        } else if let lastSaveLocation = lastSaveLocation {
            saveLocation = lastSaveLocation
            showToast(dt: lastSaveLocation.lastupdated)
        } else {
            self.errorMessage = error.localizedDescription
        }
    }

    func showToast(dt:TimeInterval) {
        isShowToast = true
        toastMessage = "Updated On: \(Date(timeIntervalSince1970: dt).description)"
    }

    func retry() {
        if let coordinates = coordinates {
            print("custom Coordinates \(coordinates)")
            self.fetchWeather(for: .init(latitude: coordinates.lat, longitude: coordinates.lon))
        } else if let coordinates = lastSaveLocation?.coord {
            print("lastSaveLocation coordinates \(coordinates)")
            self.fetchWeather(for: .init(latitude: coordinates.lat, longitude: coordinates.lon))
        } else {
            locationService.requestLocation()
            locationService.locationPublisher
                .delay(for: .seconds(0.5), scheduler: RunLoop.main) // Small delay to let hardware "warm up"
                .first()
                .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] result in
                switch result {
                case .success(let coordinates):
                    print(coordinates)
                    self?.fetchWeather(for: coordinates)
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            })
            .store(in: &cancellables)
        }
    }
}

// MARK:-  Mock View Model
extension WeatherViewModel {
    static func mockViewModel() -> WeatherViewModel {
        let mockWeatherAPIService = MockWeatherAPIService()
            mockWeatherAPIService.mockWeatherResponse = CurrentWeatherResponse.sampleData
            mockWeatherAPIService.mockForecastResponse = ForecastResponse.sampleData

        let mockLocationService = MockLocationService()
        mockLocationService.mockCoordinate = .init(latitude: 25.2048, longitude: 55.2708)

        return WeatherViewModel(weatherService: mockWeatherAPIService, locationService: mockLocationService)
    }
}

