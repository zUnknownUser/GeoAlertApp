//
//  OnboardingView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @Namespace private var animation

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to GeoAlert 🚀",
            subtitle: "Get automatic alerts when approaching important locations.",
            systemImage: "location.circle.fill"
        ),
        OnboardingPage(
            title: "Share with Family & Friends 👨‍👩‍👧‍👦",
            subtitle: "Easily share locations with your loved ones in a smart way.",
            systemImage: "person.3.fill"
        ),
        OnboardingPage(
            title: "Alerts, Your Way 🕒",
            subtitle: "Customize distance, categories, and stay notified precisely.",
            systemImage: "bell.circle.fill"
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.82, green: 0.86, blue: 0.90),
                        Color(red: 0.90, green: 0.92, blue: 0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack {
                    HStack {
                        Spacer()
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                hasSeenOnboarding = true
                            }) {
                                Text("Skip")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    .padding(.horizontal)

                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { index in
                            VStack(spacing: 30) {
                                Spacer()

                                Image(systemName: pages[index].systemImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width * 0.4)
                                    .foregroundColor(.blue)
                                    .shadow(radius: 10)
                                    .padding(.bottom, 10)
                                    .scaleEffect(currentPage == index ? 1.0 : 0.9)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentPage)

                                Text(pages[index].title)
                                    .font(.system(size: 26, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)

                                Text(pages[index].subtitle)
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)

                                Spacer()

                                if index == pages.count - 1 {
                                    Button(action: {
                                        withAnimation(.easeOut(duration: 0.5)) {
                                            hasSeenOnboarding = true
                                        }
                                    }) {
                                        Text("Get Started")
                                            .font(.headline)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                Color.blue
                                                    .cornerRadius(16)
                                                    .shadow(radius: 10)
                                            )
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 30)
                                            .scaleEffect(currentPage == pages.count - 1 ? 1.05 : 1.0)
                                            .animation(
                                                Animation.easeInOut(duration: 1)
                                                    .repeatForever(autoreverses: true),
                                                value: currentPage
                                            )
                                    }
                                    .padding(.bottom, 40)
                                }
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .interactive))
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
