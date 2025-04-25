//
//  Evento.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import Foundation
import FirebaseFirestore

struct Event: Identifiable {
    var id: String
    var userID: String
    var title: String
    var description: String
    var imageURL: String?
    var latitude: Double
    var longitude: Double
    var timestamp: Timestamp
    var comments: [String]
}

struct Comment: Identifiable {
    var userID: String
    var text: String
    var timestamp: Timestamp
}
