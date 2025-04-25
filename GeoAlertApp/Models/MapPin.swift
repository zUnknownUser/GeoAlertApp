//
//  MapPin.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import Foundation
import MapKit

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
