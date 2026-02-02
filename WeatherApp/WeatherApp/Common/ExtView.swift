//
//  ExtView.swift
//  WeatherApp
//
//  Created by Ashish on 01/02/26.
//

import Foundation
import SwiftUI

extension View {
    func weatherRowStyle(backgroundColor: Color) -> some View {
        self
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(backgroundColor)
    }
}
