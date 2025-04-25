//
//  CommunityListView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import SwiftUI

struct CommunityChatView: View {
    @ObservedObject var viewModel: CommunityChatViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    // Passando corretamente a `community` para o viewModel
    init(community: Community) {
        self.viewModel = CommunityChatViewModel(community: community)
    }

    var body: some View {
        VStack {
            // Exibe as mensagens
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(message.sender)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Text(formattedDate(message.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                Text(message.text)
                                    .font(.body)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                            }
                            .id(message.id)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Se a comunidade estiver fechada, mostrar a mensagem
            if !viewModel.community.isActive {
                Text("Esta comunidade está fechada. Não é possível enviar mensagens.")
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .padding()
            }

            Divider()

            // Campo de texto para enviar mensagem
            HStack {
                TextField("Digite uma mensagem...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)
                    .disabled(!viewModel.community.isActive) // Desabilitar campo se a comunidade estiver fechada

                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.newMessage.isEmpty || !viewModel.community.isActive ? .gray : .blue)
                }
                .disabled(viewModel.newMessage.isEmpty || !viewModel.community.isActive)
            }
            .padding()

            // Botão para fechar a comunidade (visível apenas para o criador/admin)
            if authViewModel.username == viewModel.community.createdBy {
                Button(action: {
                    closeCommunity()
                }) {
                    Text("Fechar Comunidade")
                        .font(.headline)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                .disabled(!viewModel.community.isActive) // Desabilitar se já estiver fechada
            }
        }
        .navigationTitle(viewModel.community.name.isEmpty ? "Comunidade" : viewModel.community.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    func sendMessage() {
        guard !viewModel.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        viewModel.sendMessage(sender: authViewModel.username ?? "Anonymous")
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func closeCommunity() {
        viewModel.closeCommunity { success in
            if success {
                print("Comunidade fechada com sucesso!")
            } else {
                print("Erro ao fechar a comunidade.")
            }
        }
    }
}
