//
//  CurrentTempRow.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import SwiftUI

struct CurrentTempRow: View {
    let currentWeather: CurrentWeatherModel

    var body: some View {
        HStack {
            // Day Name (e.g., Tuesday)
            CurrentTempRowData(temperature: Int(currentWeather.tempMin), rowType: .min)
                .frame(alignment: .leading)

            Spacer()
            CurrentTempRowData(temperature: Int(currentWeather.temp), rowType: .current)
                .frame(alignment: .center)

            Spacer()
            CurrentTempRowData(temperature: Int(currentWeather.tempMax), rowType: .max)
                .frame(alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .foregroundColor(.white)
        .previewLayout(.sizeThatFits)
        .background(Color.init(hex: currentWeather.weatherType.backgroundThemeColor))
    }
}

struct CurrentTempRowData: View {
    var temperature: Int
    var rowType: CurrentTempRowDataType

    enum CurrentTempRowDataType:String {
        case max = "max"
        case current = "Current"
        case min = "min"
    }

    var body: some View {
        VStack {
            // Day Name (e.g., Tuesday)
            Text("\(temperature)°")
                .font(.body)
                .frame(alignment: .center)

            // Temperature
            Text(rowType.rawValue)
                .font(.body)
                .frame(alignment: .center)
        }
        .previewLayout(.sizeThatFits)
    }
}


#Preview("Row") {
    let model = CurrentWeatherModel.init(from: CurrentWeatherResponse.mock(type: .cloudy, temp: 12))

    VStack(spacing: 0) {
        // Previewing different weather scenarios
        CurrentTempRow(currentWeather: model)
    }
}
