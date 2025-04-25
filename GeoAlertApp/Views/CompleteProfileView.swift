//
//  CompleteProfileView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//
import SwiftUI

struct CompleteProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Almost there! 🚀")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text("Choose your username")
                    .foregroundColor(.white.opacity(0.8))
                    .font(.headline)

                TextField("Enter your name", text: $username)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                Button(action: {
                    Task {
                        let success = await authViewModel.saveUsername(username: username)
                        if success {
                            withAnimation {
                                showSuccess = true
                            }
                            // Não precisa mais setar authViewModel.profileCompleted aqui,
                            // pois já é feito na função saveUsername após o sucesso no Firestore.
                        } else {
                            // Tratar erro ao salvar
                            print("Erro ao salvar o username.")
                        }
                    }
                }) {
                    Text("Save & Continue")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .disabled(username.isEmpty)

                if showSuccess {
                    Text("Profile completed successfully! 🎉")
                        .foregroundColor(.green)
                        .font(.footnote)
                        .padding(.top, 12)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    CompleteProfileView()
        .environmentObject(AuthViewModel())
}
