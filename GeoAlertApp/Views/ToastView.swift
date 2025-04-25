//
//  ToastView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(
                BlurView(style: .systemUltraThinMaterialDark)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
            )
            .padding(.horizontal, 20)
            .shadow(radius: 5)
    }
}

