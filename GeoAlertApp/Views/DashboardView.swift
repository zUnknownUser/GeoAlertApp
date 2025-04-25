//
//  DashboardView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//


import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: GeoAlertViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    summarySection

                    recentLocationsSection

                    topVisitedLocationsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard 📈")
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.97, blue: 1.0),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }

    private var summarySection: some View {
        VStack(spacing: 12) {
            Text("Summary")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                StatCard(title: "Active Locations", value: "\(viewModel.locations.filter { $0.isActive }.count)")
                StatCard(title: "Favorites", value: "\(viewModel.locations.filter { $0.isFavorite }.count)")
            }
        }
    }

    private var recentLocationsSection: some View {
        VStack(spacing: 12) {
            Text("Recent Locations")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.locations.isEmpty {
                Text("No locations added yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(viewModel.locations.prefix(5)) { location in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.name)
                            .font(.headline)
                        Text(location.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
        }
    }

    private var topVisitedLocationsSection: some View {
        VStack(spacing: 12) {
            Text("Top Locations")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .center, spacing: 8) {
                Text("Tracking number of visits coming soon!")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.blue)

            Text(title)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    DashboardView(viewModel: GeoAlertViewModel())
}
