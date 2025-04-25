//
//  CommunityViewModel.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import Foundation

import FirebaseFirestore

class CommunityViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchMessages()
    }

    func fetchMessages() {
        listener = db.collection("community")
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
        let message = Message(text: newMessage, sender: sender, timestamp: Date())
        do {
            _ = try db.collection("community").addDocument(from: message)
            newMessage = ""
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    

    deinit {
        listener?.remove()
    }
}
