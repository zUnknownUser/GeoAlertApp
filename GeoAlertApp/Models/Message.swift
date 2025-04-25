
//  Message.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.


import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var sender: String
    var timestamp: Date
}
