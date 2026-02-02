//
//  MockLocationService.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import CoreLocation
import Combine

// MARK: - Mock Location Service for Testing
final class MockLocationService: LocationServiceProtocol {
    private let subject = PassthroughSubject<Result<CLLocationCoordinate2D, LocationError>, Never>()

    var mockCoordinate: CLLocationCoordinate2D?
    var mockError: LocationError?

    // Expose a publisher that conforms to the protocol's expected name and type
    var locationPublisher: AnyPublisher<Result<CLLocationCoordinate2D, LocationError>, Never> {
        if let error = mockError {
            return Just(.failure(error)).eraseToAnyPublisher()
        }

        if let coordinate = mockCoordinate {
            return Just(.success(coordinate)).eraseToAnyPublisher()
        }

        // Fallback to an internal subject so tests can send values dynamically if desired
        return subject.eraseToAnyPublisher()
    }

    func requestLocation() {
        if let error = mockError {
            subject.send(.failure(error))
            return
        }
        if let coordinate = mockCoordinate {
            subject.send(.success(coordinate))
            return
        }
        subject.send(.failure(.unavailable))
    }
    func requestPermission() {}
}
