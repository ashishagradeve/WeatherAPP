//
//  NetworkService.swift
//  WeatherApp
//
//  Created by Ashish on 30/01/26.
//


import Foundation
import Combine

// MARK: - Network Error
enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noData, .noData):
            return true
        case (.unknown, .unknown):
            return true
        case let (.serverError(a), .serverError(b)):
            return a == b
        case let (.decodingError(a), .decodingError(b)):
            return (a as NSError).domain == (b as NSError).domain && (a as NSError).code == (b as NSError).code
        case let (.networkError(a), .networkError(b)):
            return (a as NSError).domain == (b as NSError).domain && (a as NSError).code == (b as NSError).code
        default:
            return false
        }
    }
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError>
}

// MARK: - Endpoint Protocol
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
    var method: HTTPMethod { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

// MARK: - Network Service Implementation
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    func request<T: Decodable>(endpoint: Endpoint) -> AnyPublisher<T, NetworkError> {
        guard var urlComponents = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        urlComponents.queryItems = endpoint.queryItems

        guard let url = urlComponents.url else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(httpResponse.statusCode)
                }

                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> NetworkError in
                print("error \(error)")

                if let networkError = error as? NetworkError {
                    return networkError
                } else if error is DecodingError {
                    return .decodingError(error)
                } else {
                    return .networkError(error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

