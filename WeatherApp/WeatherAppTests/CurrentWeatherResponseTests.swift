//
//  CurrentWeatherResponseTests.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import Testing
import Foundation
@testable import WeatherApp 

@Suite("CurrentWeatherResponse Decoding & Encoding Tests")
@MainActor
struct CurrentWeatherResponseTests {

    // MARK: - Mock Data

    private let validJSON = """
    {
        "coord": { "lon": 72.87, "lat": 19.07 },
        "dt": 1706611200,
        "main": {
            "temp": 30.5,
            "temp_min": 28.0,
            "temp_max": 32.0
        },
        "weather": [
            { "main": "Rain" }
        ]
    }
    """.data(using: .utf8)!

    // MARK: - Decoding Tests

    @Test("Decode valid JSON with nested 'main' and 'weather' array")
    func testDecodingValidJSON() throws {
        let decoder = JSONDecoder()
        let response = try decoder.decode(CurrentWeatherResponse.self, from: validJSON)

        #expect(response.dt == 1706611200)
        #expect(response.coord.lat == 19.07)
        #expect(response.temp == 30.5)
        #expect(response.tempMin == 28.0)
        #expect(response.tempMax == 32.0)

        // Asserting the weatherType mapping
        #expect(response.weatherType == .rainy)
    }

    @Test("Fallback to .cloudy when 'weather' array is empty")
    func testDecodingEmptyWeatherArray() throws {
        let jsonString = """
        {
            "coord": { "lon": 0, "lat": 0 },
            "dt": 12345,
            "main": { "temp": 20, "temp_min": 15, "temp_max": 25 },
            "weather": []
        }
        """
        let data = jsonString.data(using: .utf8)!
        let response = try JSONDecoder().decode(CurrentWeatherResponse.self, from: data)

        #expect(response.weatherType == .cloudy)
    }

    // MARK: - Encoding Tests

    @Test("Verify encoding preserves the original nested JSON structure")
    func testEncodingSymmetry() throws {
        // Given an existing response object
        let decoder = JSONDecoder()
        let originalResponse = try decoder.decode(CurrentWeatherResponse.self, from: validJSON)

        // When encoded
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalResponse)

        // Then decoded back
        let roundTripResponse = try decoder.decode(CurrentWeatherResponse.self, from: encodedData)

        #expect(roundTripResponse.temp == originalResponse.temp)
        #expect(roundTripResponse.weatherType == originalResponse.weatherType)
    }

    // MARK: - Validation/Error Tests

    @Test("Decoding fails when required 'main' key is missing")
    func testDecodingMissingKey() {
        let missingMainJSON = """
        {
            "coord": { "lon": 0, "lat": 0 },
            "dt": 12345,
            "weather": []
        }
        """.data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(CurrentWeatherResponse.self, from: missingMainJSON)
        }
    }
}
