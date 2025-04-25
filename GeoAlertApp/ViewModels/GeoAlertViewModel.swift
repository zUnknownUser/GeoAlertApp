//
// GeoAlertViewModel.swift
// GeoAlertApp
//
// Created by Lucas Amorim on 25/04/25.
//

import SwiftUI
import MapKit
import CoreLocation
import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


// MARK: - ViewModel
final class GeoAlertViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var locations: [GeoLocation] = []
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var showingAddLocation = false
    @Published var newLocationName = ""
    @Published var newLocationAddress = ""
    @Published var newLocationRadius: Double = 200.0
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var internalAlertMessage: String? = nil
    @Published var mapType: MKMapType = .standard
    @Published var currentTheme: AppTheme = .claro
    @Published var events: [Event] = []
    @Published var onlineUserCount: Int = 0


    // MARK: - Private Properties
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var localSearch: MKLocalSearch?

    // MARK: - Init
    override init() {
        super.init()
        configureLocationManager()
        requestLocationAuthorization()
        requestNotificationPermission()
        loadLocations()
    }
}

// MARK: - Location Manager Setup
extension GeoAlertViewModel {
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Para iOS 14+
        if #available(iOS 14.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        }
    }

    internal func requestLocationAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
}

// MARK: - Notification Setup
extension GeoAlertViewModel {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            print(granted ? "[✅] Notificações autorizadas." : "[⚠️] Permissão de notificações negada.")
        }
    }
    
    func fetchOnlineUsers(completion: @escaping ([UserLocation]) -> Void) {
        let db = Firestore.firestore()

        db.collection("users").whereField("isOnline", isEqualTo: true).getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Erro ao buscar usuários online: \(error?.localizedDescription ?? "Erro desconhecido")")
                completion([])
                return
            }

            var onlineUsers: [UserLocation] = []

            for document in snapshot.documents {
                let data = document.data()
                if let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double {
                    let userLocation = UserLocation(
                        userID: document.documentID,
                        latitude: latitude,
                        longitude: longitude
                    )
                    onlineUsers.append(userLocation)
                }
            }

            print("Usuários online encontrados: \(onlineUsers.count)") // Mostrar a quantidade de usuários encontrados
            completion(onlineUsers)
        }
    }

    
    func fetchOnlineUserCount() {
        let db = Firestore.firestore()
        
        // Consultando todos os usuários que estão online
        db.collection("users").whereField("isOnline", isEqualTo: true).getDocuments { (snapshot, error) in
            if let error = error {
                print("Erro ao buscar usuários online: \(error.localizedDescription)")
                return
            }

            // Atualize o contador de usuários online
            self.onlineUserCount = snapshot?.documents.count ?? 0
        }
    }


    func triggerNotification(for locationName: String) {
        let content = UNMutableNotificationContent()
        content.title = "📍 Alerta de Proximidade"
        content.body = "Você está próximo de: \(locationName)"
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[❌] Erro ao enviar notificação: \(error.localizedDescription)")
            } else {
                print("[🔔] Notificação enviada para: \(locationName)")
            }
        }
    }
}

// Método para atualizar a localização do usuário no Firebase
func updateLocationInFirebase(latitude: Double, longitude: Double) {
    guard let userID = Auth.auth().currentUser?.uid else {
        print("Usuário não autenticado.")
        return
    }

    let db = Firestore.firestore()
    let userRef = db.collection("users").document(userID)

    // Atualiza a localização do usuário no Firestore
    userRef.setData([
        "latitude": latitude,
        "longitude": longitude
    ], merge: true) { error in
        if let error = error {
            print("Erro ao atualizar coordenadas no Firebase: \(error.localizedDescription)")
        } else {
            print("Localização atualizada com sucesso no Firebase.")
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension GeoAlertViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        authorizationStatus = manager.authorizationStatus
        print("Authorization Status: \(authorizationStatus.rawValue)")

        
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            print("Iniciando atualização de localização")
            
            if #available(iOS 14.0, *) {
                if locationManager.accuracyAuthorization != .fullAccuracy {
                    locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "TrackUser") { error in
                        if let error = error {
                            print("Erro ao solicitar precisão total: \(error.localizedDescription)")
                        }
                    }
                }
            }

            
        case .denied, .restricted:
            print("Localização negada/restringida - mostre alerta ao usuário")
        case .notDetermined:
            manager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func toggleFavorite(for location: GeoLocation) {
        guard let index = locations.firstIndex(where: { $0.id == location.id }) else { return }
        locations[index].isFavorite.toggle()
        saveLocations()
        print("[⭐️] Favorito atualizado para: \(locations[index].name) → \(locations[index].isFavorite ? "Favorito" : "Normal")")
    }
    
    
    func calculateETA(to location: GeoLocation, transportType: MKDirectionsTransportType, completion: @escaping (String?) -> Void) {
        guard let userCoordinate = userLocation else {
            completion(nil)
            return
        }

        let source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = transportType

        let directions = MKDirections(request: request)
        directions.calculateETA { response, error in
            if let travelTime = response?.expectedTravelTime {
                let minutes = Int(travelTime / 60)
                completion("\(minutes) min")
            } else {
                completion(nil)
            }
        }
    }
    
    func updateMapStyle(style: String) {
        // Futuramente podemos mudar estilo do mapa aqui.
        // Por enquanto, apenas deixa vazio para evitar erro no SettingsView.
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        userLocation = location.coordinate
        
        region.center = location.coordinate
        
        region.span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        
        print("[📍] Localização do usuário atualizada: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[❌] Erro no Location Manager: \(error.localizedDescription)")

        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                // Acesso negado, verifique as permissões de localização
                print("[❌] Erro: Acesso à localização foi negado. Verifique as permissões no dispositivo.")
            case .locationUnknown:
                // Localização desconhecida, tente mais tarde
                print("[❌] Erro: Localização desconhecida. Tente novamente mais tarde.")
            case .network:
                // Erro de rede, problema na conexão
                print("[❌] Erro: Problema de rede. Verifique a conexão com a internet.")
            case .headingFailure:
                // Falha ao obter a direção (para o uso de bússolas)
                print("[❌] Erro: Falha ao obter a direção.")
            case .regionMonitoringDenied:
                // O monitoramento de região foi negado
                print("[❌] Erro: O monitoramento da região foi negado.")
            case .regionMonitoringFailure:
                // Falha no monitoramento de região
                print("[❌] Erro: Falha no monitoramento da região.")
            case .regionMonitoringSetupDelayed:
                // Configuração de monitoramento da região foi atrasada
                print("[❌] Erro: Configuração do monitoramento da região atrasada.")
            default:
                print("[❌] Erro desconhecido no Location Manager: \(clError.localizedDescription)")
            }
        } else {
            // Caso o erro não seja do tipo `CLError`, apenas mostraremos o erro genérico
            print("[❌] Erro desconhecido no Location Manager: \(error.localizedDescription)")
        }
    }


    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let index = self.locations.firstIndex(where: { $0.id.uuidString == region.identifier }),
              self.locations[index].isActive else { return }

        self.locations[index].visitCount += 1
        self.saveLocations()

        self.triggerNotification(for: self.locations[index].name)

        DispatchQueue.main.async {
            self.internalAlertMessage = "📍 You are near: \(self.locations[index].name)"
        }
    }

    func updateLocation(location: GeoLocation, newName: String, newRadius: Double) {
        if let index = locations.firstIndex(where: { $0.id == location.id }) {
            locations[index].name = newName
            locations[index].radius = newRadius
            saveLocations()
            print("[✏️] Localização atualizada: \(newName)")
        }
    }


}

// MARK: - Location Management
extension GeoAlertViewModel {
    func centerMapOnUserLocation() {
        guard let userLocation = userLocation else { return }
        region.center = userLocation
        print("[🗺️] Mapa centralizado na localização do usuário.")
    }

    func addPointOnMap(at coordinate: CLLocationCoordinate2D) {
        selectedCoordinate = coordinate
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let error = error {
                print("[❌] Erro ao geocodificar: \(error.localizedDescription)")
                return
            }
            if let placemark = placemarks?.first {
                self.newLocationAddress = self.formatAddress(from: placemark)
                self.showingAddLocation = true
                print("[📌] Endereço encontrado: \(self.newLocationAddress)")
            }
        }
    }

    func searchAddress() {
        guard !newLocationAddress.isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = newLocationAddress
        request.region = region
        localSearch?.cancel()
        localSearch = MKLocalSearch(request: request)
        localSearch?.start { [weak self] response, error in
            guard let self = self else { return }
            if let error = error {
                print("[❌] Erro na busca: \(error.localizedDescription)")
                return
            }
            self.searchResults = response?.mapItems ?? []
            if let first = response?.mapItems.first {
                self.region.center = first.placemark.coordinate
                self.selectedCoordinate = first.placemark.coordinate
                self.newLocationAddress = self.formatAddress(from: first.placemark)
                print("[🔎] Endereço localizado e centralizado no mapa.")
            }
        }
    }

    func addLocation() {
        guard !newLocationName.isEmpty, let coordinate = selectedCoordinate else { return }
        let location = GeoLocation(
            name: newLocationName,
            address: newLocationAddress,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: newLocationRadius
        )
        locations.append(location)
        saveLocations()
        startMonitoring(location)
        resetNewLocationFields()
        showingAddLocation = false
        selectedCoordinate = nil
        print("[✅] Localização adicionada: \(location.name)")
    }

    func removeLocation(_ location: GeoLocation) {
        locations.removeAll { $0.id == location.id }
        saveLocations()
        stopMonitoring(location)
        print("[🗑️] Localização removida: \(location.name)")
    }

    func toggleLocationActive(_ location: GeoLocation) {
        guard let index = locations.firstIndex(where: { $0.id == location.id }) else { return }
        locations[index].isActive.toggle()
        saveLocations()
        if locations[index].isActive {
            startMonitoring(locations[index])
            print("[🔵] Monitoramento ativado para: \(locations[index].name)")
        } else {
            stopMonitoring(locations[index])
            print("[⚪️] Monitoramento desativado para: \(locations[index].name)")
        }
    }

    private func startMonitoring(_ location: GeoLocation) {
        let region = CLCircularRegion(center: location.coordinate, radius: location.radius, identifier: location.id.uuidString)
        region.notifyOnEntry = true
        locationManager.startMonitoring(for: region)
    }

    private func stopMonitoring(_ location: GeoLocation) {
        locationManager.monitoredRegions
            .filter { $0.identifier == location.id.uuidString }
            .forEach { locationManager.stopMonitoring(for: $0) }
    }
    
    
    // Buscar usuários próximos dentro do raio especificado
    func fetchNearbyUsers(radius: Double, completion: @escaping ([UserLocation]) -> Void) {
        guard let userLocation = userLocation else { return }
        let db = Firestore.firestore()

        db.collection("users").getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Erro ao buscar usuários: \(error?.localizedDescription ?? "Erro desconhecido")")
                completion([])
                return
            }

            var nearbyUsers: [UserLocation] = []

            for document in snapshot.documents {
                let data = document.data()
                if let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double {
                    let distance = self.haversine(lat1: userLocation.latitude, lon1: userLocation.longitude, lat2: latitude, lon2: longitude)

                    // Verificar se o usuário está dentro do raio especificado
                    if distance <= radius {
                        let userLocation = UserLocation(
                            userID: document.documentID,
                            latitude: latitude,
                            longitude: longitude
                        )
                        nearbyUsers.append(userLocation)
                    }
                }
            }

            print("Usuários próximos encontrados: \(nearbyUsers.count)")
            completion(nearbyUsers)
        }
    }


    }

    
    




// MARK: - Persistence
extension GeoAlertViewModel {
    func saveLocations() {
        guard let data = try? JSONEncoder().encode(locations) else { return }
        UserDefaults.standard.set(data, forKey: "SavedLocations")
        print("[💾] Localizações salvas.")
    }

    func loadLocations() {
        guard let data = UserDefaults.standard.data(forKey: "SavedLocations"),
              let savedLocations = try? JSONDecoder().decode([GeoLocation].self, from: data) else { return }
        locations = savedLocations
        locations.filter { $0.isActive }.forEach(startMonitoring)
        print("[📂] Localizações carregadas.")
    }
    
    func updateTheme(to themeName: String) {
        switch themeName {
        case "Escuro":
            currentTheme = .escuro
        case "Neon":
            currentTheme = .neon
        case "Pastel":
            currentTheme = .pastel
        default:
            currentTheme = .claro
        }
    }
    
    func startMonitoringSharedLocation(_ location: SharedLocation) {
        let region = CLCircularRegion(
            center: location.coordinate,
            radius: location.radius,
            identifier: location.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = false

        locationManager.startMonitoring(for: region)
        print("[👫] Monitorando local compartilhado: \(location.locationName)")
    }

    private func formatAddress(from placemark: CLPlacemark) -> String {
        let address = [
            placemark.subThoroughfare,
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.postalCode,
            placemark.country
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
        return address
    }

    private func resetNewLocationFields() {
        newLocationName = ""
        newLocationAddress = ""
        newLocationRadius = 200.0
    }
}

enum AppTheme: String, CaseIterable {
    case claro = "Claro"
    case escuro = "Escuro"
    case neon = "Neon"
    case pastel = "Pastel"
}

extension GeoAlertViewModel {
    // Criar um evento
    func createEvent(title: String, description: String, imageURL: String?, latitude: Double, longitude: Double, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let eventData: [String: Any] = [
            "userID": userID,
            "title": title,
            "description": description,
            "imageURL": imageURL ?? "",
            "latitude": latitude,
            "longitude": longitude,
            "timestamp": Timestamp(),
            "comments": []  
        ]
        
        let db = Firestore.firestore()
        db.collection("events").addDocument(data: eventData) { error in
            if let error = error {
                print("Erro ao criar evento: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    // Buscar eventos próximos com base na localização do usuário
    func fetchNearbyEvents(radius: Double, completion: @escaping ([Event]) -> Void) {
        guard let userLocation = userLocation else { return }
        let db = Firestore.firestore()

        db.collection("events").getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print("Erro ao buscar eventos: \(error?.localizedDescription ?? "Erro desconhecido")")
                completion([])
                return
            }

            var events: [Event] = []

            for document in snapshot.documents {
                let data = document.data()
                if let latitude = data["latitude"] as? Double,
                   let longitude = data["longitude"] as? Double {
                    let distance = self.haversine(lat1: userLocation.latitude, lon1: userLocation.longitude, lat2: latitude, lon2: longitude)

                    if distance <= radius {
                        // Mapeando os comentários de String para Comment
                        let commentsData = data["comments"] as? [String] ?? []
                        let comments = commentsData.map { commentText in
                            Comment(userID: "user_id_here", text: commentText, timestamp: Timestamp())
                        }

                        let event = Event(
                            id: document.documentID,  // Usando o ID do documento no Firestore
                            userID: data["userID"] as! String,
                            title: data["title"] as! String,
                            description: data["description"] as! String,
                            imageURL: data["imageURL"] as? String,
                            latitude: latitude,
                            longitude: longitude,
                            timestamp: data["timestamp"] as! Timestamp,
                            likes: data["likes"] as? [String] ?? [],  // Corrigido para garantir que likes seja um array de String (caso não tenha, será um array vazio)
                            comments: comments  // Agora, passando a lista de Comment
                        )
                        events.append(event)
                    }

                }
            }

            completion(events)
        }
    }
    
    // Função para adicionar comentário
        func addComment(eventID: String, comment: Comment) {
            let db = Firestore.firestore()
            let eventRef = db.collection("events").document(eventID)

            // Adicionando o comentário na subcoleção "comments"
            eventRef.collection("comments").addDocument(data: [
                "userID": comment.userID,
                "text": comment.text,
                "timestamp": comment.timestamp
            ]) { error in
                if let error = error {
                    print("Erro ao adicionar comentário: \(error.localizedDescription)")
                } else {
                    print("Comentário adicionado com sucesso!")
                }
            }
        }

        // Função para curtir o evento
        func toggleLike(eventID: String, userID: String) {
            let db = Firestore.firestore()
            let eventRef = db.collection("events").document(eventID)

            eventRef.getDocument { document, error in
                if let document = document, document.exists {
                    var event = try? document.data(as: Event.self)
                    var updatedLikes = event?.likes ?? []

                    // Verifica se o usuário já curtiu o evento
                    if updatedLikes.contains(userID) {
                        updatedLikes.removeAll { $0 == userID }
                    } else {
                        updatedLikes.append(userID)
                    }

                    // Atualiza o evento com a nova lista de curtidas
                    eventRef.updateData(["likes": updatedLikes]) { error in
                        if let error = error {
                            print("Erro ao atualizar curtidas: \(error.localizedDescription)")
                        } else {
                            print("Curtida atualizada com sucesso!")
                        }
                    }
                } else {
                    print("Evento não encontrado.")
                }
            }
        }

        // Função para postar mídia (fotos ou vídeos)
        func postMedia(eventID: String, mediaData: Data, mediaType: String, userID: String) {
            let storage = Storage.storage()
            let mediaRef = storage.reference().child("events/\(eventID)/media/\(UUID().uuidString).\(mediaType)")

            mediaRef.putData(mediaData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Erro ao enviar mídia: \(error.localizedDescription)")
                    return
                }

                mediaRef.downloadURL { url, error in
                    if let error = error {
                        print("Erro ao obter URL da mídia: \(error.localizedDescription)")
                        return
                    }
                    guard let mediaURL = url?.absoluteString else { return }

                    let newMedia = Media(userID: userID, mediaURL: mediaURL, mediaType: mediaType, timestamp: Timestamp())
                    let db = Firestore.firestore()
                    let eventRef = db.collection("events").document(eventID)

                    eventRef.collection("media").addDocument(data: [
                        "userID": newMedia.userID,
                        "mediaURL": newMedia.mediaURL,
                        "mediaType": newMedia.mediaType,
                        "timestamp": newMedia.timestamp
                    ]) { error in
                        if let error = error {
                            print("Erro ao adicionar mídia: \(error.localizedDescription)")
                        } else {
                            print("Mídia adicionada com sucesso!")
                        }
                    }
                }
            }
        }

    // Função para calcular distância entre dois pontos usando fórmula Haversine
    func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0  // Raio da Terra em km
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return R * c  // Distância em km
    }
}
