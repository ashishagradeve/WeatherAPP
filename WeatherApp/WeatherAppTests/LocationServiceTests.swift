//
//  Test.swift
//  LocationServiceTests
//
//  Created by Ashish on 01/02/26.
//

import Testing
import CoreLocation
import Combine
@testable import WeatherApp 

@Suite("Location Service Tests")
@MainActor
struct LocationServiceTests {

    /// Tests that the publisher correctly emits a value when a mock success is triggered.
    /// Note: This uses the Mock to verify the protocol-based flow.
    @Test("Mock Location Service emits success coordinate")
    func testMockLocationSuccess() async throws {
        let mock = MockLocationService()
        let expectedCoordinate = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
        mock.mockCoordinate = expectedCoordinate

        var cancellables = Set<AnyCancellable>()

        // We use a confirmation to handle the async nature of the publisher
        await confirmation("Coordinate received") { confirm in
            mock.locationPublisher
                .sink { result in
                    if case .success(let coordinate) = result {
                        #expect(coordinate.latitude == expectedCoordinate.latitude)
                        #expect(coordinate.longitude == expectedCoordinate.longitude)
                        confirm()
                    }
                }
                .store(in: &cancellables)

            mock.requestLocation()
        }
    }

    @Test("Mock Location Service emits unauthorized error")
    func testMockLocationUnauthorized() async throws {
        let mock = MockLocationService()
        mock.mockError = .unauthorized

        var cancellables = Set<AnyCancellable>()

        await confirmation("Error received") { confirm in
            mock.locationPublisher
                .sink { result in
                    if case .failure(let error) = result {
                        #expect(error == .unauthorized)
                        #expect(error.localizedDescription.contains("Settings"))
                        confirm()
                    }
                }
                .store(in: &cancellables)

            mock.requestLocation()
        }
    }
}
