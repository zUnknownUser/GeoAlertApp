
//  GeoAlertAppApp.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GeoAlertViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            AlertsView(viewModel: viewModel)
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }

            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
