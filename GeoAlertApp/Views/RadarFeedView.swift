//
//  RadarFeedView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import SwiftUI

struct RadarFeedView: View {
    @ObservedObject var viewModel: GeoAlertViewModel

    var body: some View {
        NavigationView {
            VStack {
                Text("Eventos Próximos")
                    .font(.title)
                    .bold()
                    .padding()

                NavigationLink(destination: CreateEventView(viewModel: viewModel)) {
                    Text("Criar Novo Evento")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()

                List(viewModel.events) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                            .padding(.bottom, 2)

                        Text(event.description)
                            .font(.subheadline)
                            .padding(.bottom, 10)

                        if let imageURL = event.imageURL, isValidURL(imageURL) {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image.resizable()
                                     .scaledToFill()
                                     .frame(height: 200)
                                     .clipped()
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipped()
                                .foregroundColor(.gray)
                        }

                        ForEach(event.comments) { comment in
                            
                            Text(comment.text)
                                .font(.footnote)
                                .padding(.top, 5)
                        }

                        NavigationLink(destination: EventDetailView(viewModel: viewModel, event: event)) {
                            Text("Ver Detalhes")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    fetchNearbyEvents()
                }

                Spacer()
            }
            .navigationBarTitle("Radar de Proximidade", displayMode: .inline)
            .padding(.bottom)
        }
    }

    // Função para verificar se a URL é válida
    func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
            return false
        }
        return true
    }

    // Buscar eventos próximos com base na localização do usuário
    func fetchNearbyEvents() {
        let radius: Double = 5.0 // Raio de 5km
        viewModel.fetchNearbyEvents(radius: radius) { fetchedEvents in
            // Atualiza diretamente o viewModel com os eventos encontrados
            viewModel.events = fetchedEvents
        }
    }
}

#Preview {
    RadarFeedView(viewModel: GeoAlertViewModel())
}
