//
//  AlertsView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//


import SwiftUI
import MapKit

struct AlertsView: View {
    @ObservedObject var viewModel: GeoAlertViewModel
    @State private var selectedLocation: GeoLocation? = nil
    @State private var showingOnlyFavorites = false
    @State private var travelTimes: [UUID: String] = [:]
    @State private var selectedTransportType: MKDirectionsTransportType = .automobile

    var filteredLocations: [GeoLocation] {
        showingOnlyFavorites ? viewModel.locations.filter { $0.isFavorite } : viewModel.locations
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)]),
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    
                    HStack(spacing: 12) {
                        transportButton(title: "🚗 Car", type: .automobile)
                        transportButton(title: "🚶‍♂️ Walk", type: .walking)
                        transportButton(title: "🚌 Transit", type: .transit)
                    }
                    .padding(.horizontal)

                    
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                showingOnlyFavorites = false
                            }
                        }) {
                            Text("All")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(showingOnlyFavorites ? Color.clear : Color.blue.opacity(0.2))
                                .foregroundColor(showingOnlyFavorites ? .primary : .blue)
                                .clipShape(Capsule())
                        }

                        Button(action: {
                            withAnimation {
                                showingOnlyFavorites = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Favorites")
                            }
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(showingOnlyFavorites ? Color.yellow.opacity(0.2) : Color.clear)
                            .foregroundColor(showingOnlyFavorites ? .yellow : .primary)
                            .clipShape(Capsule())
                        }

                        Spacer()
                    }
                    .padding(.horizontal)

                    if filteredLocations.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.gray.opacity(0.4))
                            Text(showingOnlyFavorites ? "No favorites found." : "No active alerts.")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(filteredLocations.sorted { $0.isFavorite && !$1.isFavorite }) { location in
                                    alertCard(for: location)
                                        .onTapGesture {
                                            selectedLocation = location
                                        }
                                        .padding(.horizontal)
                                        .onAppear {
                                            viewModel.calculateETA(to: location, transportType: selectedTransportType) { eta in
                                                if let eta = eta {
                                                    travelTimes[location.id] = eta
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Active Alerts")
            .sheet(item: $selectedLocation) { location in
                EditLocationView(viewModel: viewModel, location: location)
            }
        }
    }

    // MARK: - Transport Button
    @ViewBuilder
    func transportButton(title: String, type: MKDirectionsTransportType) -> some View {
        Button(action: {
            withAnimation {
                selectedTransportType = type
                refreshETAs()
            }
        }) {
            Text(title)
                .font(.footnote)
                .fontWeight(selectedTransportType == type ? .bold : .regular)
                .foregroundColor(selectedTransportType == type ? .blue : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedTransportType == type ? Color.blue.opacity(0.2) : Color.clear)
                .clipShape(Capsule())
        }
    }
    

    func refreshETAs() {
        travelTimes.removeAll()
        for location in filteredLocations {
            viewModel.calculateETA(to: location, transportType: selectedTransportType) { eta in
                if let eta = eta {
                    travelTimes[location.id] = eta
                }
            }
        }
    }

    // MARK: - Alert Card
    @ViewBuilder
    func alertCard(for location: GeoLocation) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(location.isActive ? .green : .gray)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(location.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if location.isFavorite {
                            Text("🔥 FAVORITE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.15))
                                .clipShape(Capsule())
                                .transition(.scale)
                        }
                    }

                    Text(location.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Alert radius: \(Int(location.radius)) meters")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let eta = travelTimes[location.id] {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text("Estimated time: \(eta)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 2)
                    }
                }

                Spacer()

                VStack(spacing: 8) {
                    Button(action: {
                        viewModel.toggleLocationActive(location)
                    }) {
                        Image(systemName: location.isActive ? "bell.fill" : "bell.slash.fill")
                            .foregroundColor(location.isActive ? .green : .gray)
                            .padding(8)
                            .background(location.isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }

                    Button(action: {
                        viewModel.toggleFavorite(for: location)
                    }) {
                        Image(systemName: location.isFavorite ? "star.fill" : "star")
                            .foregroundColor(location.isFavorite ? .yellow : .gray)
                            .padding(8)
                            .background(Color.yellow.opacity(location.isFavorite ? 0.2 : 0.08))
                            .clipShape(Circle())
                    }

                    Button(action: {
                        deleteLocation(location)
                    }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(
            BlurView(style: .systemUltraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 5)
    }

    private func deleteLocation(_ location: GeoLocation) {
        withAnimation {
            viewModel.removeLocation(location)
        }
    }
}


#Preview {
    AlertsView(viewModel: GeoAlertViewModel())
}
