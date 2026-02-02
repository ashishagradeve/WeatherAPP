//
//  LoadingView.swift
//  WeatherApp
//
//  Created by Ashish on 31/01/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            Text("Loading...")
                .foregroundColor(.white)
                .padding(.top, 80)
        }
    }
}

#Preview {
    LoadingView()
}

