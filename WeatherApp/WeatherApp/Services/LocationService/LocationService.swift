//
//  LocationService.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Location Error
enum LocationError: Error, LocalizedError {
    case unauthorized
    case unavailable
    case failed

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Location access denied. Please enable location services in Settings."
        case .unavailable:
            return "Location services are unavailable."
        case .failed:
            return "Failed to get your location. Please try again."
        }
    }
}

// MARK: - Location Service Protocol
protocol LocationServiceProtocol {
    var locationPublisher: AnyPublisher<Result<CLLocationCoordinate2D, LocationError>, Never> { get }
    func requestLocation()
    func requestPermission()
}

// MARK: - Location Service Implementation
final class LocationService: NSObject, LocationServiceProtocol {
    private let locationManager: CLLocationManager
    private let locationSubject = PassthroughSubject<Result<CLLocationCoordinate2D, LocationError>, Never>()

    var locationPublisher: AnyPublisher<Result<CLLocationCoordinate2D, LocationError>, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 1000 // Update every 1km
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        let status = locationManager.authorizationStatus

        switch status {
        case .notDetermined:
            requestPermission()
        case .restricted, .denied:
            locationSubject.send(.failure(.unauthorized))
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            locationSubject.send(.failure(.unavailable))
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationSubject.send(.failure(.unavailable))
            return
        }

        // 2. Check if the horizontal accuracy is valid and meets our threshold
        // location.horizontalAccuracy: lower values = higher precision
        if location.horizontalAccuracy > 0 && location.horizontalAccuracy <= kCLLocationAccuracyKilometer {

            // 3. Send the accurate coordinate
            locationSubject.send(.success(location.coordinate))

            // 4. STOP updates immediately to save battery
            manager.stopUpdatingLocation()
        } else {
            // Log or handle the "ignored" low-accuracy updates
            print("Received location with accuracy: \(location.horizontalAccuracy)m. Waiting for better...")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationSubject.send(.failure(.unauthorized))
            default:
                locationSubject.send(.failure(.failed))
            }
        } else {
            locationSubject.send(.failure(.failed))
        }
    }
}
