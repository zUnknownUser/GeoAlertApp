//
//  CreateEventView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//


import SwiftUI
import MapKit

struct CreateEventView: View {
    @ObservedObject var viewModel: GeoAlertViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var imageURL: String = ""
    @State private var locationQuery: String = ""  // A consulta de local que o usuário digita
    @State private var latitude: Double? = nil
    @State private var longitude: Double? = nil
    @State private var searchResults: [MKMapItem] = []  // Lista de locais sugeridos
    @State private var isCreatingEvent: Bool = false
    @State private var isEventConfirmed: Bool = false  // Nova variável para controlar a confirmação do evento
    
    let locationManager = CLLocationManager()  // Para pegar a localização do usuário se necessário

    var body: some View {
        NavigationView {
            ScrollView {  // Envolvendo tudo com ScrollView para garantir que o conteúdo role em dispositivos pequenos
                VStack(spacing: 20) {  // Ajustando o espaçamento entre os elementos
                    Text("Criar Evento")
                        .font(.title)
                        .bold()
                        .padding(.top)

                    // Título do evento
                    TextField("Título do evento", text: $title)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                        .padding(.horizontal)

                    // Descrição do evento
                    TextField("Descrição do evento", text: $description)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // URL da imagem
                    TextField("URL da imagem (opcional)", text: $imageURL)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Campo de pesquisa para local
                    TextField("Digite o nome do local", text: $locationQuery)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: locationQuery) { newValue in
                            searchLocations(query: newValue)  // Realizar a busca à medida que o texto é alterado
                        }
                        .padding(.horizontal)
                    
                    // Exibir sugestões de locais
                    List(searchResults, id: \.self) { item in
                        Button(action: {
                            selectLocation(item)  // Preencher latitude/longitude ao selecionar um local
                        }) {
                            Text(item.name ?? "Local não encontrado")
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(height: 200)  // Limitar a altura da lista de resultados
                    .padding(.horizontal)

                    // Botão de confirmação para criar evento
                    if isEventConfirmed {
                        Button(action: {
                            createEvent()  // Chama a função para criar o evento
                        }) {
                            Text(isCreatingEvent ? "Criando..." : "Confirmar Criação do Evento")
                                .padding()
                                .foregroundColor(.white)
                                .background(isCreatingEvent ? Color.gray : Color.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                        .disabled(isCreatingEvent)  // Desabilita o botão enquanto o evento está sendo criado
                    }
                    else {
                        Button(action: {
                            // Apenas confirma que o evento deve ser criado
                            isEventConfirmed = true
                        }) {
                            Text("Confirmar Criação")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(8)
                        }
                        .padding()
                    }

                    Spacer(minLength: 20)
                }
                .padding(.bottom)  // Adicionando um pouco de espaço no fundo
            }
            .navigationTitle("Criar Evento")
        }
    }

    // Função de busca de locais com MKLocalSearch
    func searchLocations(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Ajuste do raio de pesquisa
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Erro na pesquisa: \(error?.localizedDescription ?? "Desconhecido")")
                return
            }
            // Atualizar os resultados com os locais encontrados
            searchResults = response.mapItems
        }
    }

    // Função para selecionar um local a partir da lista de sugestões
    func selectLocation(_ item: MKMapItem) {
        latitude = item.placemark.coordinate.latitude
        longitude = item.placemark.coordinate.longitude
        locationQuery = item.name ?? "Local selecionado"
        searchResults = []  // Limpa a lista de sugestões após a seleção
    }

    // Função para criar o evento
    func createEvent() {
        guard let lat = latitude, let lon = longitude, !title.isEmpty, !description.isEmpty else {
            print("Por favor, preencha todos os campos corretamente.")
            return
        }

        isCreatingEvent = true

        // Criar o evento com a função do ViewModel
        viewModel.createEvent(title: title, description: description, imageURL: imageURL, latitude: lat, longitude: lon) { success in
            isCreatingEvent = false
            if success {
                print("Evento criado com sucesso!")
                presentationMode.wrappedValue.dismiss()  // Volta para a tela anterior após criar o evento
            } else {
                print("Falha ao criar o evento.")
            }
        }
    }
}

#Preview {
    CreateEventView(viewModel: GeoAlertViewModel())
}
