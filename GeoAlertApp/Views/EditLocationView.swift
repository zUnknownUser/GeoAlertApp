//
//  EditLocationView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI


struct EditLocationView: View {
    @ObservedObject var viewModel: GeoAlertViewModel
    var location: GeoLocation

    @State private var newName: String
    @State private var newRadius: Double

    @Environment(\.presentationMode) var presentationMode

    init(viewModel: GeoAlertViewModel, location: GeoLocation) {
        self.viewModel = viewModel
        self.location = location
        _newName = State(initialValue: location.name)
        _newRadius = State(initialValue: location.radius)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editar Local")) {
                    TextField("Nome do Local", text: $newName)

                    VStack(alignment: .leading) {
                        Text("Raio de Proximidade")
                            .font(.headline)
                        Slider(value: $newRadius, in: 100...1000, step: 50)
                        Text("\(Int(newRadius)) metros")
                            .font(.caption)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Editar Alerta")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        saveChanges()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func saveChanges() {
        viewModel.updateLocation(location: location, newName: newName, newRadius: newRadius)
    }
}   
