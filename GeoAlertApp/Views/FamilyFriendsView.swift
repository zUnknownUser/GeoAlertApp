//
//  FamilyFriendsView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct FamilyFriendsView: View {
    @StateObject var friendsVM = FriendsViewModel()
    @State private var showingAddFriend = false
    @State private var selectedFriend: Friend?
    @State private var showingAddSharedLocation = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    if friendsVM.friends.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("Nenhum amigo adicionado.")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 100)
                    } else {
                        List {
                            ForEach(friendsVM.friends) { friend in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(friend.name)
                                        .font(.headline)
                                    Text(friend.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)

                                    if !friend.sharedLocations.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                ForEach(friend.sharedLocations) { loc in
                                                    Text(loc.locationName)
                                                        .font(.caption)
                                                        .padding(6)
                                                        .background(Color.blue.opacity(0.2))
                                                        .cornerRadius(8)
                                                }
                                            }
                                        }
                                    }

                                    Button(action: {
                                        selectedFriend = friend
                                        showingAddSharedLocation = true
                                    }) {
                                        Label("Adicionar Local Compartilhado", systemImage: "plus.circle")
                                            .font(.caption)
                                            .padding(.top, 4)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .onDelete(perform: deleteFriend)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationTitle("Family & Friends")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddFriend = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView(friendsVM: friendsVM)
            }
            .sheet(item: $selectedFriend) { friend in
                AddSharedLocationView(friendsVM: friendsVM, friend: friend)
            }
        }
    }

    private func deleteFriend(at offsets: IndexSet) {
        for index in offsets {
            let friend = friendsVM.friends[index]
            friendsVM.removeFriend(friend)
        }
    }
}

#Preview {
    FamilyFriendsView()
}
