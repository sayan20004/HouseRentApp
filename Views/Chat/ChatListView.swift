//
//  ChatListView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import SwiftUI
import Combine

class ChatListViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var isLoading = false
    
    func loadConversations() {
        isLoading = true
        Task {
            do {
                conversations = try await ChatService.shared.fetchConversations()
            } catch {
                print(error)
            }
            isLoading = false
        }
    }
}

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    LoadingView()
                } else if viewModel.conversations.isEmpty {
                    EmptyStateView(text: "No messages yet")
                } else {
                    List(viewModel.conversations) { conversation in
                        NavigationLink(destination: ChatDetailView(conversation: conversation)) {
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(Text(String(conversation.otherParticipant(myId: appState.currentUser?.id ?? "")?.name.prefix(1) ?? "?")))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(conversation.otherParticipant(myId: appState.currentUser?.id ?? "")?.name ?? "Unknown")
                                        .font(.headline)
                                    Text(conversation.property.title)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(conversation.lastMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
            .onAppear { viewModel.loadConversations() }
        }
    }
}
