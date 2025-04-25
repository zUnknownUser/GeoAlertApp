//
//  LoginView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var showPassword = false

    var body: some View {
        ZStack {
            // 🎨 Background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // 🚀 Logo + Title
                VStack(spacing: 8) {
                    Image(systemName: "location.fill.viewfinder")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                        .shadow(radius: 10)

                    Text("GeoAlert")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 5)

                    Text(isSignUp ? "Create your account" : "Welcome back!")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)

                // ✏️ Form fields
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    ZStack(alignment: .trailing) {
                        Group {
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.trailing, 12)
                        }
                    }
                }
                .padding(.horizontal)

                // 🔥 Login/Signup button
                Button(action: {
                    if isSignUp {
                        authViewModel.signUp(email: email, password: password)
                    } else {
                        authViewModel.login(email: email, password: password)
                    }
                }) {
                    Text(isSignUp ? "Sign Up" : "Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .padding(.top, 8)

                // 🌀 Loading
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top)
                }

                // 🚨 Error messages
                if let error = authViewModel.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }

                Spacer()

                // 🔄 Switch between login/signup
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                        authViewModel.authError = nil
                    }
                }) {
                    Text(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                        .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}

