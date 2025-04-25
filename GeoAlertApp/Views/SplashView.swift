//
//  SplashView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//


import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false

    var body: some View {
        if isActive {
            if hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        } else {
            VStack {
                Spacer()
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                    .shadow(radius: 10)
                    .scaleEffect(1.2)
                    .transition(.scale)

                Text("GeoAlert 🚀")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.blue)
                    .padding(.top, 20)
                
                Spacer()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                    .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.88, blue: 0.92),
                        Color(red: 0.90, green: 0.92, blue: 0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
