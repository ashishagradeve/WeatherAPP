//
//  MockNetworkService.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import Foundation
import Combine

final class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: Any?
    var mockError: NetworkError?

    /// Delay in seconds before returning data (simulates network latency)
    var delay: TimeInterval = 0

    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        let publisher: AnyPublisher<T, NetworkError>

        if let error = mockError {
            return Fail(error: error)
                .delay(for: .milliseconds(Int(delay)), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else if let response = mockResponse as? T {
            return Just(response)
                .delay(for: .milliseconds(Int(delay)), scheduler: RunLoop.main)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: NetworkError.noData)
                .delay(for: .milliseconds(Int(delay)), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
    }
}
