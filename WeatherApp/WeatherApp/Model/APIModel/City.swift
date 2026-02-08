//
//  City.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import Foundation

// MARK: - Forecast City
struct City: Codable, Hashable {
    let id: Int
    let name: String
    let coord: Coordinates
    let country: String
}
