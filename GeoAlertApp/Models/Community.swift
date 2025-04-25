//
//  Community.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import Foundation
import FirebaseFirestore

struct Community: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var createdBy: String
    var timestamp: Date
    var isActive: Bool = true
}
