//
//  SettingsView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: GeoAlertViewModel
    @Environment(\.presentationMode) var presentationMode

    @AppStorage("selectedTheme") private var selectedTheme: String = "Light"
    @AppStorage("selectedMapStyle") private var selectedMapStyle: String = "Standard"
    @State private var showClearConfirmation = false
    @State private var showLogoutConfirmation = false
    @StateObject private var friendsVM = FriendsViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.background(for: viewModel.currentTheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        header

                        settingsSection(title: "🎨 App Theme") {
                            themeButton("Light")
                            themeButton("Dark")
                            themeButton("Neon")
                            themeButton("Pastel")
                        }

                        settingsSection(title: "🗺️ Map Style") {
                            mapStyleButton("Standard", value: "Standard")
                            mapStyleButton("Satellite", value: "Satellite")
                            mapStyleButton("Hybrid", value: "Hybrid")
                        }

                        settingsSection(title: "🧑‍🤝‍🧑 Family & Friends") {
                            NavigationLink(destination: FamilyFriendsView()) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.3.fill")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading) {
                                        Text("Share locations with friends and family! 🔥")
                                            .foregroundColor(ThemeManager.primaryText(for: viewModel.currentTheme))
                                            .font(.headline)
                                        Text("Manage your contacts and shared locations.")
                                            .foregroundColor(ThemeManager.secondaryText(for: viewModel.currentTheme))
                                            .font(.footnote)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }

                        settingsSection(title: "⚙️ Other Options") {
                            versionInfo()
                            clearLocationsButton()
                            contactSupportButton()
                            logoutButton() // 👈 adicionamos o botão logout aqui!
                        }

                        Spacer()

                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeManager.accentColor(for: viewModel.currentTheme))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            .confirmationDialog("Tem certeza que deseja apagar todas as localizações?", isPresented: $showClearConfirmation) {
                Button("Apagar Tudo", role: .destructive) {
                    viewModel.locations.removeAll()
                    viewModel.saveLocations()
                }
            }
            .confirmationDialog("Tem certeza que deseja sair?", isPresented: $showLogoutConfirmation) {
                Button("Logout", role: .destructive) {
                    authViewModel.logout()
                }
                Button("Cancelar", role: .cancel) { }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("Settings")
                .font(.largeTitle)
                .bold()
                .foregroundColor(ThemeManager.primaryText(for: viewModel.currentTheme))
            Text("Manage your GeoAlert 🚀")
                .font(.subheadline)
                .foregroundColor(ThemeManager.secondaryText(for: viewModel.currentTheme))
        }
        .padding(.top)
    }

    // MARK: - Sections
    @ViewBuilder
    func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeManager.primaryText(for: viewModel.currentTheme))

            VStack(spacing: 12) {
                content()
            }
            .padding()
            .background(ThemeManager.cardBackground(for: viewModel.currentTheme))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }

    @ViewBuilder
    func themeButton(_ title: String) -> some View {
        Button(action: {
            withAnimation {
                selectedTheme = title
                viewModel.updateTheme(to: title)
            }
        }) {
            HStack {
                Text(title)
                    .foregroundColor(ThemeManager.primaryText(for: viewModel.currentTheme))
                Spacer()
                if selectedTheme == title {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.accentColor(for: viewModel.currentTheme))
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    func mapStyleButton(_ title: String, value: String) -> some View {
        Button(action: {
            withAnimation {
                selectedMapStyle = value
                viewModel.updateMapStyle(style: value)
            }
        }) {
            HStack {
                Text(title)
                    .foregroundColor(ThemeManager.primaryText(for: viewModel.currentTheme))
                Spacer()
                if selectedMapStyle == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeManager.accentColor(for: viewModel.currentTheme))
                }
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    func versionInfo() -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(ThemeManager.accentColor(for: viewModel.currentTheme))
            VStack(alignment: .leading) {
                Text("Versão")
                    .font(.headline)
                    .foregroundColor(ThemeManager.primaryText(for: viewModel.currentTheme))
                Text(appVersion())
                    .font(.subheadline)
                    .foregroundColor(ThemeManager.secondaryText(for: viewModel.currentTheme))
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    func clearLocationsButton() -> some View {
        Button(role: .destructive) {
            showClearConfirmation = true
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                Text("Apagar Todas Localizações")
                    .font(.headline)
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    func contactSupportButton() -> some View {
        Button {
            openEmail()
        } label: {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.green)
                Text("Fale Conosco")
                    .font(.headline)
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    func logoutButton() -> some View {
        Button(role: .destructive) {
            showLogoutConfirmation = true
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.red)
                Text("Logout")
                    .font(.headline)
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Extra Functions
    func appVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return "v\(version)"
        }
        return "v1.0"
    }

    func openEmail() {
        let email = "contact@geoalert.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView(viewModel: GeoAlertViewModel())
        .environmentObject(AuthViewModel())
}
