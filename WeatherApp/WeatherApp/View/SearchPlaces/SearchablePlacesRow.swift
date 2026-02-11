//
//  SearchablePlacesRow.swift
//  WeatherApp
//
//  Created by Ashish on 11/02/26.
//

import SwiftUI

struct SearchablePlacesRow: View {

    let title:String
    let subtitle:String
    let cellClicked: () -> Void

    var body: some View {
        Button {
            cellClicked()
        } label: {
            VStack(alignment: .leading) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(subtitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SearchablePlacesRow(
        title: "Cupertino",
        subtitle: "California, United States",
        cellClicked: {}
    )
}
