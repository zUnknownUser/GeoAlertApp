//
//  AddSharedLocationView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI
import MapKit

struct AddSharedLocationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var friendsVM: FriendsViewModel
    var friend: Friend
    
    @State private var locationName: String = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), // São Paulo como centro inicial
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var radius: Double = 200.0

    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, interactionModes: .all, annotationItems: selectedCoordinate.map { [MapPin(coordinate: $0)] } ?? []) { pin in
                    MapMarker(coordinate: pin.coordinate)
                }
                .onTapGesture(perform: selectLocation)
                .frame(height: 300)
                .cornerRadius(16)
                .padding()

                Form {
                    Section(header: Text("Informações do Local")) {
                        TextField("Nome do Local", text: $locationName)
                        Slider(value: $radius, in: 50...1000, step: 50) {
                            Text("Raio")
                        }
                        Text("Raio: \(Int(radius)) metros")
                    }
                }

                Spacer()

                Button("Salvar Local") {
                    saveSharedLocation()
                }
                .disabled(locationName.isEmpty || selectedCoordinate == nil)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding()
            }
            .navigationTitle("Novo Local Compartilhado")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func selectLocation() {
        // Pega o centro atual do mapa como localização selecionada
        selectedCoordinate = region.center
        print("[📍] Localização selecionada: \(region.center.latitude), \(region.center.longitude)")
    }

    private func saveSharedLocation() {
        guard let coordinate = selectedCoordinate else { return }
        friendsVM.addSharedLocation(to: friend, locationName: locationName, coordinate: coordinate, radius: radius)
        presentationMode.wrappedValue.dismiss()
    }
}


