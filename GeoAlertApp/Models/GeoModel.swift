//
//  GeoModel.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import Foundation
import CoreLocation
// MARK: - Model
struct GeoLocation: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var radius: Double
    var isActive: Bool = true
    var isFavorite: Bool = false
    var visitCount: Int = 0 // <-- NOVO!

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: GeoLocation, rhs: GeoLocation) -> Bool {
        return lhs.id == rhs.id
    }
}
