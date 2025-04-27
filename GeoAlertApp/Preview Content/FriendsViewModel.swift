//
//  FriendsViewModel.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import Foundation
import CoreLocation


final class FriendsViewModel: ObservableObject {
    @Published var friends: [Friend] = []

    init() {
        loadFriends()
    }

    // Adicionar novo amigo
    func addFriend(name: String, email: String, picture: String? = nil) {
        let newFriend = Friend(name: name, email: email, profilePictureURL: picture, sharedLocations: [])
        friends.append(newFriend)
        saveFriends()
    }

    // Adicionar local compartilhado
    func addSharedLocation(to friend: Friend, locationName: String, coordinate: CLLocationCoordinate2D, radius: Double) {
        guard let index = friends.firstIndex(where: { $0.id == friend.id }) else { return }
        let shared = SharedLocation(locationName: locationName, coordinate: coordinate, radius: radius)
        friends[index].sharedLocations.append(shared)
        saveFriends()
    }

    // Remover amigo
    func removeFriend(_ friend: Friend) {
        friends.removeAll { $0.id == friend.id }
        saveFriends()
    }

    // Remover local compartilhado
    func removeSharedLocation(friend: Friend, location: SharedLocation) {
        guard let friendIndex = friends.firstIndex(where: { $0.id == friend.id }) else { return }
        friends[friendIndex].sharedLocations.removeAll { $0.id == location.id }
        saveFriends()
    }

    // MARK: - Persistência (UserDefaults por enquanto)
    private func saveFriends() {
        if let data = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(data, forKey: "SavedFriends")
        }
    }
    
    private func loadFriends() {
        guard let data = UserDefaults.standard.data(forKey: "SavedFriends"),
              let saved = try? JSONDecoder().decode([Friend].self, from: data) else { return }
        friends = saved

        // Agora para cada local compartilhado, começar monitoramento:
        let geoAlertVM = GeoAlertViewModel() // <- instancia ou injeta depois

        for friend in friends {
            for sharedLoc in friend.sharedLocations {
                geoAlertVM.startMonitoringSharedLocation(sharedLoc)
            }
        }
    }

}
