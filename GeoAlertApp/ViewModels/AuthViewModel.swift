//
//  AuthViewModel.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var isLoading = true
    @Published var authError: String?
    @Published var profileCompleted: Bool = false
    @Published var username: String?

    private let db = Firestore.firestore()

    init() {
        checkUser()
    }

    func checkUser() {
        self.user = Auth.auth().currentUser
        if let user = self.user {
            // Verificar se o perfil do usuário está completo no Firestore
            db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        print("Erro ao buscar dados do usuário: \(error.localizedDescription)")
                        // Lógica de tratamento de erro, talvez manter profileCompleted como false
                    } else if let snapshot = snapshot, snapshot.exists {
                        self?.profileCompleted = snapshot.data()?["username"] != nil // Ajuste para o seu campo de nickname
                    } else {
                        self?.profileCompleted = false // Perfil não encontrado
                    }
                }
            }
        } else {
            self.isLoading = false
        }
    }

    func login(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.authError = error.localizedDescription
                } else {
                    self?.user = result?.user
                    self?.checkUserProfileCompletion() // Verificar perfil após login
                }
            }
        }
    }

    func signUp(email: String, password: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                    self?.isLoading = false
                } else if let user = result?.user {
                    self?.user = user
                    self?.profileCompleted = false // conta criada, falta username
                    self?.isLoading = false
                }
            }
        }
    }


    func saveUsername(username: String) async -> Bool {
        guard let uid = user?.uid else { return false }
        do {
            let snapshot = try await db.collection("users").whereField("username", isEqualTo: username).getDocuments()
            if !snapshot.isEmpty {
                DispatchQueue.main.async {
                    self.authError = "Este nickname já está em uso. Por favor, escolha outro."
                }
                return false
            } else {
                try await db.collection("users").document(uid).setData(["username": username], merge: true)
                DispatchQueue.main.async {
                    self.profileCompleted = true
                    self.username = username
                    self.authError = nil
                }
                return true
            }
        } catch {
            print("Erro ao verificar ou salvar o username: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.authError = "Ocorreu um erro ao salvar o seu nickname. Tente novamente."
            }
            return false
        }
    }


    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
        self.profileCompleted = false
    }
    
    func fetchUsername() {
        guard let uid = user?.uid else { return }
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let data = snapshot?.data(), let storedUsername = data["username"] as? String {
                    self?.username = storedUsername
                }
            }
        }
    }


    private func checkUserProfileCompletion() {
        guard let uid = user?.uid else {
            profileCompleted = false
            username = nil
            return
        }
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Erro ao verificar perfil: \(error.localizedDescription)")
                    self?.profileCompleted = false
                    self?.username = nil
                    return
                }
                if let data = snapshot?.data(), let storedUsername = data["username"] as? String {
                    self?.profileCompleted = true
                    self?.username = storedUsername
                } else {
                    self?.profileCompleted = false
                    self?.username = nil
                }
            }
        }
    }
}
