////
////  CommunityView.swift
////  GeoAlertApp
////
////  Created by Lucas Amorim on 26/04/25.
////

import SwiftUI

struct CommunityView: View {
    @ObservedObject var viewModel = CommunityViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        VStack {
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
                            .id(message.id) // 👈 pra scroll automático
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                }
            }

            Divider()

            HStack {
                TextField("Digite uma mensagem...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(viewModel.newMessage.isEmpty ? .gray : .blue)
                }
                .disabled(viewModel.newMessage.isEmpty)
            }
            .padding()
        }
        .navigationTitle("🌐 Comunidade")
        .navigationBarTitleDisplayMode(.inline)
    }

    func sendMessage() {
        guard !viewModel.newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.sendMessage(sender: authViewModel.username ?? "Anonymous")
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    CommunityView()
}
