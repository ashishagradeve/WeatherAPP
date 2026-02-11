//
//  SavedPlacesRow.swift
//  WeatherApp
//
//  Created by Ashish on 11/02/26.
//

import SwiftUI

struct SavedPlacesRow: View {

    @Binding var isFav:Bool
    let fullName:String
    let cellClicked: () -> Void

    var body: some View {
        Button {
            cellClicked()
        } label: {
            HStack {
                Text(fullName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    isFav.toggle()
                } label: {
                    Image(systemName: "heart")
                        .symbolVariant(isFav ? .fill : .none)
                }.frame(alignment: .trailing)
            }
        }
    }
}

#Preview("SearchPlacesRow Preview") {
    @Previewable @State var isFav = false
    return SavedPlacesRow(
        isFav: .constant(isFav),
        fullName: "Cupertino, California",
        cellClicked: {}
    )
}
#Preview("Interactive") {
    struct Wrapper: View {
        @State private var isFav = true
        var body: some View {
            SavedPlacesRow(
                isFav: $isFav,
                fullName: "London, United Kingdom",
                cellClicked: { print("Cell tapped") }
            )
            .padding()
        }
    }
    return Wrapper()
}

