//
//  CommunityListViewModel.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import Foundation
import FirebaseFirestore

class CommunityListViewModel: ObservableObject {
    @Published var communities: [Community] = []
    private var db = Firestore.firestore()

    init() {
        fetchCommunities()
    }

    func fetchCommunities() {
        db.collection("communities")
            .whereField("isActive", isEqualTo: true)
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Erro ao buscar comunidades: \(error.localizedDescription)")
                    return
                }

                if let documents = snapshot?.documents {
                    self.communities = documents.compactMap { doc in
                        try? doc.data(as: Community.self)
                    }
                }
            }
    }

    func createCommunity(name: String, createdBy: String, completion: @escaping (Bool) -> Void) {
        let newCommunity = Community(name: name, createdBy: createdBy, timestamp: Date(), isActive: true)

        do {
            _ = try db.collection("communities").addDocument(from: newCommunity)
            completion(true)
        } catch {
            print("Erro ao criar comunidade: \(error.localizedDescription)")
            completion(false)
        }
    }
}
