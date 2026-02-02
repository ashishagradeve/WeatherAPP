//
//  ToastView.swift
//  WeatherApp
//
//  Created by Ashish on 02/02/26.
//

import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.black.opacity(0.8)))
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .medium))
            .shadow(radius: 4)
    }
}
