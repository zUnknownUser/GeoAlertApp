//
//  AddFriendView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import SwiftUI

struct AddFriendView: View {
    @ObservedObject var friendsVM: FriendsViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var email = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informações do Amigo")) {
                    TextField("Nome", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Novo Amigo")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        friendsVM.addFriend(name: name, email: email)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    AddFriendView(friendsVM: FriendsViewModel())
//}
