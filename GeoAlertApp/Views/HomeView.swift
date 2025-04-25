//
//  HomeView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//
 

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var viewModel: GeoAlertViewModel
    @State private var showingAddLocation = false
    @State private var animateLocationButton = false
    @State private var placeDescription: String = ""
    @State private var showingCommunityView = false
    @State private var showingRadarView = false
    @State private var nearbyUsers: [UserLocation] = []

    var dynamicBackground: LinearGradient {
        switch viewModel.currentTheme {
        case .claro:
            return LinearGradient(colors: [Color.white, Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
        case .escuro:
            return LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
        case .neon:
            return LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pastel:
            return LinearGradient(colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                dynamicBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    buildRefinedHeader()

                    ZStack(alignment: .topTrailing) {
                        MapViewRepresentable(
                            region: $viewModel.region,
                            annotations: viewModel.locations,  // As localizações salvas
                            userLocation: viewModel.userLocation,
                            mapType: viewModel.mapType,
                            userAnnotations: nearbyUsers.map { user -> MKPointAnnotation in
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = CLLocationCoordinate2D(latitude: user.latitude, longitude: user.longitude)
                                annotation.title = "Usuário Próximo"
                                return annotation
                            } // Passando os usuários próximos
                        )
                        .frame(height: 280)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)

                        Button {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                animateLocationButton.toggle()
                                viewModel.centerMapOnUserLocation()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                animateLocationButton = false
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .rotationEffect(.degrees(animateLocationButton ? 360 : 0))
                                .foregroundColor(.blue)
                                .padding(10)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(16)
                    }

                    Spacer()
                }

                // **Bolinha verde no topo centralizado** para mostrar usuários online
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 40, height: 40)
                            Text("\(viewModel.onlineUserCount)") // Exibe o número de usuários online
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(.top, 40)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }

                VStack {
                    Spacer()
                    HStack {
                        // Botão da Comunidade (esquerda)
                        Button(action: {
                            showingCommunityView = true
                        }) {
                            Image(systemName: "globe")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    LinearGradient(colors: [
                                        ThemeManager.accentColor(for: viewModel.currentTheme),
                                        ThemeManager.accentColor(for: viewModel.currentTheme).opacity(0.7)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                        .sheet(isPresented: $showingCommunityView) {
                            CommunityListView()
                                .environmentObject(authViewModel)
                        }

                        Spacer()

                        // Botão de Adicionar Localização (direita)
                        Button(action: {
                            showingAddLocation = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    LinearGradient(colors: [
                                        ThemeManager.accentColor(for: viewModel.currentTheme),
                                        ThemeManager.accentColor(for: viewModel.currentTheme).opacity(0.7)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                        .sheet(isPresented: $showingAddLocation) {
                            AddLocationView(viewModel: viewModel)
                        }

                        // Botão do Radar (nova adição)
                        Button(action: {
                            showingRadarView = true
                        }) {
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding(20)
                                .background(
                                    LinearGradient(colors: [
                                        ThemeManager.accentColor(for: viewModel.currentTheme),
                                        ThemeManager.accentColor(for: viewModel.currentTheme).opacity(0.7)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                        .sheet(isPresented: $showingRadarView) {
                            RadarFeedView(viewModel: viewModel) // A nova tela do feed de proximidade
                                .environmentObject(authViewModel)
                        }
                    }
                }

                if let message = viewModel.internalAlertMessage {
                    VStack {
                        ToastInternalView(message: message)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .zIndex(10)
                        Spacer()
                    }
                    .padding(.top, 50)
                    .animation(.easeOut(duration: 0.4), value: viewModel.internalAlertMessage)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                viewModel.internalAlertMessage = nil
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.requestLocationAuthorization()
                fetchPlaceDescription()
                authViewModel.fetchUsername()
                loadOnlineUsers() // Carregar todos os usuários online
                viewModel.fetchOnlineUserCount() // Contar os usuários online
            }
        }
    }

    // MARK: - HEADER
    @ViewBuilder
    func buildRefinedHeader() -> some View {
        ZStack(alignment: .bottomLeading) {
            ZStack {
                Image("geo-pattern")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipped()

                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.4), Color.clear]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            .frame(height: 140)
            .overlay(BlurView(style: .systemUltraThinMaterialDark))
            .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
            .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 10) {
                Text("GeoAlert 🚀")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                if let username = authViewModel.username, !username.isEmpty {
                    Text("Hello, \(username) 👋")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.85))
                }

                if !placeDescription.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.white.opacity(0.9))
                        Text(placeDescription)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - RoundedCorner Helper
    struct RoundedCorner: Shape {
        var radius: CGFloat
        var corners: UIRectCorner

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }

    // Função para carregar a descrição do lugar
    func fetchPlaceDescription() {
        guard let location = viewModel.userLocation else { return }
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
            if let placemark = placemarks?.first {
                let cidade = placemark.locality ?? ""
                let bairro = placemark.subLocality ?? ""
                DispatchQueue.main.async {
                    placeDescription = "\(bairro), \(cidade)"
                }
            }
        }
    }

    // MARK: - Função para carregar todos os usuários online
    func loadOnlineUsers() {
        viewModel.fetchOnlineUsers { users in
            self.nearbyUsers = users
        }
    }
}

#Preview {
    HomeView(viewModel: GeoAlertViewModel())
        .environmentObject(AuthViewModel()) // Precisamos fornecer o EnvironmentObject para a Preview também
}
