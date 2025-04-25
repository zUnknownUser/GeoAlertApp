//
//  CommunityListViewOne.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//


import SwiftUI

struct CommunityListView: View {
    @StateObject var viewModel = CommunityListViewModel() // Usando o ViewModel com o listener
    @EnvironmentObject var authViewModel: AuthViewModel // Ambiente do authViewModel
    @State private var showingCreateCommunity = false // Controle para a tela de criação de comunidade

    var body: some View {
        NavigationView {
            // Lista de Comunidades
            List(viewModel.communities) { community in
                NavigationLink(destination: CommunityChatView(community: community)) {
                    VStack(alignment: .leading) {
                        Text(community.name)
                            .font(.headline)
                            .foregroundColor(.primary) // Mantém o nome com destaque
                        Text("Criado por: \(community.createdBy)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5) // Um pouco de espaçamento
                }
            }
            .navigationTitle("Comunidades 🌐")
            .toolbar {
                // Botão para abrir a criação de comunidade
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCreateCommunity = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .sheet(isPresented: $showingCreateCommunity) {
                        // Passa o ViewModel e AuthViewModel para a tela de criação de comunidade
                        CreateCommunityView(viewModel: viewModel)
                            .environmentObject(authViewModel) // Para garantir que o AuthViewModel é usado corretamente
                    }
                }
            }
        }
    }
}

#Preview {
    CommunityListView()
        .environmentObject(AuthViewModel()) // Passando o AuthViewModel para o Preview
}
