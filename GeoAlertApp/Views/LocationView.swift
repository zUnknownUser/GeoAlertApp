//
//  LocationView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI
import MapKit

struct AddLocationView: View {
    @ObservedObject var viewModel: GeoAlertViewModel
    @State private var searchQuery = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var showToast = false

    var body: some View {
        NavigationView {
            ZStack {
                // 🌈 Background
                LinearGradient(gradient: Gradient(colors: [Color(.systemTeal).opacity(0.1), Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 🔹 Title
                        VStack(alignment: .leading, spacing: 6) {
                            Text("New Location")
                                .font(.largeTitle)
                                .bold()
                            Text("Set a point of interest and receive proximity alerts.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        // 🔎 Search
                        glassCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.blue)
                                    TextField("Search for a place...", text: $searchQuery, onCommit: searchPlaces)
                                        .textInputAutocapitalization(.words)
                                        .disableAutocorrection(true)
                                }

                                if isSearching {
                                    ProgressView()
                                }

                                if !searchResults.isEmpty {
                                    Divider().padding(.vertical, 8)

                                    ForEach(searchResults, id: \.self) { item in
                                        Button(action: {
                                            selectPlace(item)
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(item.name ?? "No Name")
                                                    .font(.headline)
                                                if let address = item.placemark.title {
                                                    Text(address)
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                        }

                        // 📍 Name + Address
                        glassCard {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                        .foregroundColor(.blue)
                                    TextField("Location name", text: $viewModel.newLocationName)
                                        .textInputAutocapitalization(.words)
                                }
                                Divider()
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.red)
                                    TextField("Address", text: $viewModel.newLocationAddress)
                                        .disabled(true)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // 🔘 Radius Slider
                        VStack(spacing: 12) {
                            Text("Proximity Radius")
                                .font(.headline)

                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                                    .frame(width: 120, height: 120)

                                Circle()
                                    .trim(from: 0.0, to: CGFloat((viewModel.newLocationRadius - 100) / 900))
                                    .stroke(
                                        AngularGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), center: .center),
                                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 120, height: 120)
                                    .animation(.easeOut(duration: 0.3), value: viewModel.newLocationRadius)

                                Text("\(Int(viewModel.newLocationRadius)) m")
                                    .font(.title3)
                                    .bold()
                            }

                            Slider(value: $viewModel.newLocationRadius, in: 100...1000, step: 50)
                                .accentColor(.blue)
                                .padding(.horizontal)
                        }

                        // 🗺️ Mini-map preview
                        if let coord = viewModel.selectedCoordinate {
                            glassCard {
                                ZStack {
                                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                                        center: coord,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )))
                                    .cornerRadius(12)
                                    .frame(height: 140)

                                    Image(systemName: "mappin.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        // ✅ Buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                viewModel.showingAddLocation = false
                            }) {
                                Text("Cancel")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(12)
                            }

                            Button(action: {
                                saveLocationWithToast()
                            }) {
                                Text("Save")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(viewModel.newLocationName.isEmpty || viewModel.selectedCoordinate == nil ? Color.gray : Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .disabled(viewModel.newLocationName.isEmpty || viewModel.selectedCoordinate == nil)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }

                // 🚀 TOAST!
                if showToast {
                    VStack {
                        ToastView(message: "Location saved successfully! 🎉")
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(1)
                        Spacer()
                    }
                    .padding(.top, 50)
                    .animation(.easeOut(duration: 0.4), value: showToast)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Search Function
    func searchPlaces() {
        guard !searchQuery.isEmpty else {
            searchResults = []
            return
        }
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        request.region = viewModel.region

        MKLocalSearch(request: request).start { response, error in
            isSearching = false
            if let response = response {
                searchResults = response.mapItems
            } else {
                searchResults = []
            }
        }
    }

    // MARK: - Select place from search
    func selectPlace(_ item: MKMapItem) {
        viewModel.newLocationName = item.name ?? "No Name"
        viewModel.newLocationAddress = item.placemark.title ?? "No Address"
        viewModel.selectedCoordinate = item.placemark.coordinate
        searchResults = []
        searchQuery = ""
    }

    // MARK: - Save with Toast
    func saveLocationWithToast() {
        viewModel.addLocation()
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showToast = false
            }
            viewModel.showingAddLocation = false
        }
    }
}

// MARK: - GlassCard Helper
@ViewBuilder
func glassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            BlurView(style: .systemThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
        )
        .padding(.horizontal)
}

// MARK: - BlurView Helper
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    AddLocationView(viewModel: GeoAlertViewModel())
}
