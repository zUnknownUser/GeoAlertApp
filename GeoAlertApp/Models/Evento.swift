//
//  Evento.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import FirebaseFirestore

struct Event: Identifiable, Decodable {
    var id: String
    var userID: String
    var title: String
    var description: String
    var imageURL: String?
    var latitude: Double
    var longitude: Double
    var timestamp: Timestamp
    var likes: [String] // Lista de IDs de usuários que curtiram o evento
    var comments: [Comment] // Lista de comentários, que é uma subcoleção no Firestore
    
    // Inicializador
    init(id: String, userID: String, title: String, description: String, imageURL: String?, latitude: Double, longitude: Double, timestamp: Timestamp, likes: [String], comments: [Comment]) {
        self.id = id
        self.userID = userID
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
    }
}

struct Comment: Identifiable, Decodable {
    var id: String  // ID único para cada comentário
    var userID: String
    var text: String
    var timestamp: Timestamp
    
    // Inicializador
    init(userID: String, text: String, timestamp: Timestamp) {
        self.id = UUID().uuidString  // Gerando um id único para o comentário
        self.userID = userID
        self.text = text
        self.timestamp = timestamp
    }
}

struct Media: Identifiable {
    @DocumentID var id: String?
    var userID: String
    var mediaURL: String
    var mediaType: String
    var timestamp: Timestamp
}
