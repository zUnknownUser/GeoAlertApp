//
//  EventDetailView.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 26/04/25.
//

import SwiftUI
import Firebase


struct EventDetailView: View {
    @ObservedObject var viewModel: GeoAlertViewModel
    @State private var event: Event
    @State private var newComment: String = ""
    @State private var newMedia: Data? = nil  // Para upload de mídia (fotos ou vídeos)

    init(viewModel: GeoAlertViewModel, event: Event) {
        self.viewModel = viewModel
        _event = State(initialValue: event)
    }

    var body: some View {
        VStack {
            // Título do evento
            Text(event.title)
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 20)
                .foregroundColor(.primary)

            // Descrição do evento
            Text(event.description)
                .font(.body)
                .padding(.top, 10)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Imagem do evento
            if let imageURL = event.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image.resizable()
                         .scaledToFill()
                         .frame(height: 250)
                         .clipped()
                         .cornerRadius(15)
                         .shadow(radius: 10)
                } placeholder: {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(50)
                }
            }

            // Curtidas e botão de curtir
            HStack {
                Text("\(event.likes.count) Curtidas")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()

                Button(action: {
                    toggleLike()
                }) {
                    Image(systemName: event.likes.contains("user_id_here") ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding(10)
                        .background(Circle().fill(Color.white).shadow(radius: 5))
                }
            }
            .padding(.horizontal)

            Divider()

            // Seção de Comentários
            Text("Comentários:")
                .font(.headline)
                .padding(.top)

            // Comentários da lista
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(event.comments) { comment in
                        VStack(alignment: .leading) {
                            Text(comment.text)
                                .font(.footnote)
                                .padding(.top, 5)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 10)
            }

            // Campo para adicionar um novo comentário
            HStack {
                TextField("Adicionar comentário...", text: $newComment)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    addComment()
                }) {
                    Text("Comentar")
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.trailing)
            }

            Divider()

            // Botão para postar mídia (fotos ou vídeos)
            Button(action: {
                postMedia()
            }) {
                Text("Postar Foto/Vídeo")
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)

            Spacer()
        }
        .navigationBarTitle("Detalhes do Evento", displayMode: .inline)
        .padding(.horizontal, 20)
    }

    // Função para adicionar um comentário
    func addComment() {
        let newCommentObj = Comment(userID: "user_id_here", text: self.newComment, timestamp: Timestamp())
        viewModel.addComment(eventID: event.id, comment: newCommentObj)
        self.newComment = ""  // Limpar o campo de comentário
    }

    // Função para curtir o evento
    func toggleLike() {
        viewModel.toggleLike(eventID: event.id, userID: "user_id_here")
    }

    // Função para postar mídia (foto ou vídeo)
    func postMedia() {
        // Aqui você pode implementar a lógica para selecionar uma imagem ou vídeo e chamá-la para upload.
        // Exemplo: Se tiver uma imagem selecionada, você chama a função:
        if let mediaData = newMedia {
            viewModel.postMedia(eventID: event.id, mediaData: mediaData, mediaType: "image", userID: "user_id_here")
        }
    }
}

//#Preview {
//    EventDetailView(viewModel: GeoAlertViewModel(), event: Event(id: "1", userID: "user1", title: "Evento de Teste", description: "Descrição do evento", imageURL: "http://image.url", latitude: 0.0, longitude: 0.0, timestamp: Timestamp(), likes: [], comments: []))
//}
//
//
////#Preview {
////    EventDetailView(viewModel: GeoAlertViewModel(), event: Event(id: "1", userID: "user1", title: "Evento de Teste", description: "Descrição do evento", imageURL: "http://image.url", latitude: 0.0, longitude: 0.0, timestamp: Timestamp(), likes: [], comments: []))
////}
