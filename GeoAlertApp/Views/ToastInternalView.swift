//
//  ToastInternalView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct ToastInternalView: View {
    var message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .background(
                BlurView(style: .systemUltraThinMaterialDark)
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            )
            .padding(.horizontal, 20)
            .shadow(radius: 6)
    }
}
