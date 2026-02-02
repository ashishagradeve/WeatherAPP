//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Weather Unavailable", systemImage: "")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .background(Color.white)
    }
}

#Preview {
    ErrorView(message: "error") {

    }
}
