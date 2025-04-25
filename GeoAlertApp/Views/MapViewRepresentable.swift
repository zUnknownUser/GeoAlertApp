//
//  MapViewRepresentable.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//


import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var annotations: [GeoLocation]
    var userLocation: CLLocationCoordinate2D?
    var mapType: MKMapType  // Tipo de mapa
    var userAnnotations: [MKPointAnnotation] = []  // Anotações para usuários próximos

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsTraffic = true
        mapView.mapType = mapType  // Define o tipo de mapa
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Atualiza a região do mapa se necessário
        let currentCenter = uiView.region.center
        let newCenter = region.center
        let distance = CLLocation(latitude: currentCenter.latitude, longitude: CLLocationDegrees(newCenter.latitude))
            .distance(from: CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude))

        if distance > 20 {
            uiView.setRegion(region, animated: true)
        }

        // Atualiza o tipo de mapa ao vivo
        if uiView.mapType != mapType {
            uiView.mapType = mapType
        }

        // Atualiza Annotations de locais
        uiView.removeAnnotations(uiView.annotations)
        let mapAnnotations = annotations.map { location in
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = location.name
            return annotation
        }
        uiView.addAnnotations(mapAnnotations)

        // Adiciona anotações para usuários próximos
        uiView.addAnnotations(userAnnotations)

        // Atualizar Overlays (círculos para os locais)
        uiView.removeOverlays(uiView.overlays)
        let circleOverlays = annotations.map { location in
            MKCircle(center: location.coordinate, radius: location.radius)
        }
        uiView.addOverlays(circleOverlays)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - COORDINATOR
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        // View para exibir as anotações no mapa
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            let identifier = "LocationAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }

        // Renderer para mostrar o círculo (overlay) de proximidade
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor.blue.withAlphaComponent(0.3)
                renderer.strokeColor = .blue
                renderer.lineWidth = 1
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
