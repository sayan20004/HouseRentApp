//
//  ChatDetailView.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import SwiftUI
import Combine

class ChatDetailViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage = ""
    @Published var isLoading = false
    
    private var timer: Timer?
    
    func loadMessages(conversationId: String) {
        Task {
            do {
                let msgs = try await ChatService.shared.fetchMessages(conversationId: conversationId)
                await MainActor.run { self.messages = msgs }
            } catch {
                print(error)
            }
        }
    }
    
    func sendMessage(conversationId: String) {
        guard !newMessage.isEmpty else { return }
        let content = newMessage
        newMessage = ""
        
        Task {
            do {
                let msg = try await ChatService.shared.sendMessage(conversationId: conversationId, content: content)
                await MainActor.run { self.messages.append(msg) }
            } catch {
                print(error)
            }
        }
    }
    
    func startPolling(conversationId: String) {
        loadMessages(conversationId: conversationId)
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.loadMessages(conversationId: conversationId)
        }
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
}

struct ChatDetailView: View {
    let conversation: Conversation
    @StateObject private var viewModel = ChatDetailViewModel()
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.sender._id == appState.currentUser?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Type a message...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: { viewModel.sendMessage(conversationId: conversation.id) }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.appPrimary)
                        .padding(8)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 2)
        }
        .navigationTitle(conversation.otherParticipant(myId: appState.currentUser?.id ?? "")?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.startPolling(conversationId: conversation.id) }
        .onDisappear { viewModel.stopPolling() }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.appPrimary : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(16)
                
                Text(formatTime(message.createdAt))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
    
    func formatTime(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: iso) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return ""
    }
}
