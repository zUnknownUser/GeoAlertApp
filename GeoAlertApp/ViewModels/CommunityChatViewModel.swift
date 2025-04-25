//
//  CommunityChatViewModel.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import Foundation
import FirebaseFirestore


class CommunityChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    var community: Community

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init(community: Community) {
        self.community = community
        fetchMessages()
    }

    func fetchMessages() {
        guard let communityId = community.id else { return }
        listener = db.collection("communities")
            .document(communityId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let documents = snapshot?.documents {
                    self.messages = documents.compactMap { doc in
                        try? doc.data(as: Message.self)
                    }
                }
            }
    }

    func sendMessage(sender: String) {
        guard !newMessage.isEmpty else { return }
        let message = Message(text: newMessage, sender: sender, timestamp: Date())
        guard let communityId = community.id else { return }
        
        do {
            _ = try db.collection("communities")
                .document(communityId) // Usando o id da comunidade para enviar a mensagem
                .collection("messages")
                .addDocument(from: message)
            newMessage = "" // Limpa o campo de mensagem após o envio
        } catch {
            print("Erro ao enviar mensagem: \(error.localizedDescription)")
        }
    }

    func closeCommunity(completion: @escaping (Bool) -> Void) {
        guard let communityId = community.id else { return completion(false) }
        db.collection("communities").document(communityId).updateData(["isActive": false]) { error in
            if let error = error {
                print("Erro ao fechar a comunidade: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
