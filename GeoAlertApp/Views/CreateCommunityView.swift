//
//  CreateCommunityView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import SwiftUI

struct CreateCommunityView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CommunityListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var communityName = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Nome da Comunidade", text: $communityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    // Garantir que o nome da comunidade não esteja vazio ou apenas com espaços/nova linha
                    guard !communityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    
                    if let username = authViewModel.username {
                        // Chama o método para criar a comunidade
                        viewModel.createCommunity(name: communityName, createdBy: username) { success in
                            if success {
                                // Se a criação foi bem-sucedida, fecha a tela atual
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                // Aqui você pode adicionar algum tipo de mensagem de erro, se quiser
                                print("Erro ao criar a comunidade!")
                            }
                        }
                    }
                }) {
                    Text("Criar Comunidade")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .disabled(communityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}


#Preview {
    CreateCommunityView(viewModel: CommunityListViewModel())
}
