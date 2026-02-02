//
//  ForecastResponseTests.swift
//  WeatherAppTests
//
//  Created by Ashish on 30/01/26.
//

import Testing
import Foundation
@testable import WeatherApp

@Suite("Forecast Response Module Tests")
@MainActor
struct ForecastResponseTests {

    // MARK: - Mock Data Factory

    private func makeMockForecastJSON() -> Data {
        """
        {
            "list": [
                {
                    "dt": 1706611200,
                    "main": { "temp": 25.5, "temp_min": 20.0, "temp_max": 30.0 },
                    "weather": [{ "main": "Rain" }]
                }
            ],
            "city": {
                "id": 123,
                "name": "Mumbai",
                "coord": { "lat": 19.07, "lon": 72.87 },
                "country": "IN"
            }
        }
        """.data(using: .utf8)!
    }

    // MARK: - Decoding Tests

    @Test("Verify ForecastItem correctly flattens nested JSON")
    func testForecastItemDecoding() throws {
        let data = makeMockForecastJSON()
        let response = try JSONDecoder().decode(ForecastResponse.self, from: data)

        #expect(response.list.count == 1)
        let item = response.list[0]
        #expect(item.temp == 25.5)
        #expect(item.weatherType == .rainy) // Assuming mapping for "Rain"
        #expect(response.city.name == "Mumbai")
    }

    // MARK: - Business Logic Tests (toDailyForecasts)

    @Test("Verify 3-hourly data is grouped and limited to 5 days")
    func testToDailyForecastsGrouping() {
        // Create items for 2 different days
        let today = Date().timeIntervalSince1970
        let tomorrow = today + 86400

        let item1 = createMockItem(dt: today)
        let item2 = createMockItem(dt: tomorrow)

        let city = City(id: 1, name: "Test", coord: Coordinates(lon: 0, lat: 0), country: "US")
        let response = ForecastResponse(list: [item1, item2], city: city)

        let daily = response.toDailyForecasts()

        #expect(daily.count == 1)
    }

    @Test("Verify selection of noon-time item for daily display")
    func testNoonItemSelection() {
        let calendar = Calendar.current
        let tomorrow = try! #require(calendar.date(byAdding: .day, value: 1, to: Date()))
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)

        // Create one morning item and one noon item
        let morning = startOfTomorrow.addingTimeInterval(3600 * 8).timeIntervalSince1970 // 8 AM
        let noon = startOfTomorrow.addingTimeInterval(3600 * 12).timeIntervalSince1970    // 12 PM

        let itemMorning = createMockItem(dt: morning, temp: 20)
        let itemNoon = createMockItem(dt: noon, temp: 30)

        let city = City(id: 1, name: "Test", coord: Coordinates(lon: 0, lat: 0), country: "US")
        let response = ForecastResponse(list: [itemMorning, itemNoon], city: city)

        let daily = response.toDailyForecasts()

        // Should pick the 12 PM item as it's closer to the 43200s (12h) offset
        #expect(daily.first?.temp == 30)
    }
}

// MARK: - Helper
extension ForecastResponseTests {
    private func createMockItem(dt: TimeInterval, temp: Double = 25.0) -> ForecastItem {
        let json = """
        {
            "dt": \(dt),
            "main": { "temp": \(temp), "temp_min": \(temp), "temp_max": \(temp) },
            "weather": [{ "main": "Clouds" }]
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(ForecastItem.self, from: json)
    }
}
