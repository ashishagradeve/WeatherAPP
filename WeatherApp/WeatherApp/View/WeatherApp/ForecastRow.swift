//
//  ForecastRow.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import SwiftUI

struct ForecastRow: View {
    let forecastItem: ForecastItemModel 

    var body: some View {
        HStack {
            // Day Name (e.g., Tuesday)
            Text(forecastItem.dayName)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Weather Icon (e.g., clear, rain, partlysunny)
            Image(forecastItem.weatherType.iconImage)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)

            // Temperature
            Text("\(Int(forecastItem.temp))°")
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .foregroundColor(.white)
        .background(Color.init(hex: forecastItem.weatherType.backgroundThemeColor))
        .previewLayout(.sizeThatFits)
    }
}



#Preview {
    VStack(spacing: 0) {
        // Previewing different weather scenarios

        ForecastRow(forecastItem: ForecastItemModel.init(from: ForecastItem.mock(addingDay:1, type: .sunny, temp: 22)
                                                        ))
        ForecastRow(forecastItem: ForecastItemModel.init(from: ForecastItem.mock(addingDay:2, type: .cloudy, temp: 33)
                                                        ))
        ForecastRow(forecastItem: ForecastItemModel.init(from: ForecastItem.mock(addingDay:3, type: .rainy, temp: 33)
                                                        ))
        ForecastRow(forecastItem: ForecastItemModel.init(from: ForecastItem.mock(addingDay:4, type: .sunny, temp: 11)
                                                        ))
        ForecastRow(forecastItem: ForecastItemModel.init(from: ForecastItem.mock(addingDay:5, type: .sunny, temp: 12)
                                                        ))
    }
}
