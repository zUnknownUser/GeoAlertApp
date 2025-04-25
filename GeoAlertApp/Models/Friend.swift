//
//  Friend.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import Foundation
import CoreLocation

struct Friend: Identifiable, Codable {
    var id = UUID()
    var name: String
    var email: String
    var profilePictureURL: String? // Opcional para foto de perfil
    var sharedLocations: [SharedLocation]
}

struct SharedLocation: Identifiable, Codable {
    var id = UUID()
    var locationName: String
    var coordinate: CLLocationCoordinate2D
    var radius: Double

    enum CodingKeys: String, CodingKey {
        case id, locationName, latitude, longitude, radius
    }

    init(id: UUID = UUID(), locationName: String, coordinate: CLLocationCoordinate2D, radius: Double) {
        self.id = id
        self.locationName = locationName
        self.coordinate = coordinate
        self.radius = radius
    }

    // Encoder personalizado
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(locationName, forKey: .locationName)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(radius, forKey: .radius)
    }

    // Decoder personalizado
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        locationName = try container.decode(String.self, forKey: .locationName)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        radius = try container.decode(Double.self, forKey: .radius)
    }
}
