//
//  ChatService.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import Foundation

class ChatService {
    static let shared = ChatService()
    
    func startConversation(propertyId: String, ownerId: String) async throws -> Conversation {
        let body = ["propertyId": propertyId, "ownerId": ownerId]
        let data = try JSONEncoder().encode(body)
        let response: APIResponse<Conversation> = try await NetworkManager.shared.request(
            endpoint: "/conversations",
            method: "POST",
            body: data
        )
        guard let conversation = response.data else { throw NetworkError.unknown }
        return conversation
    }
    
    func fetchConversations() async throws -> [Conversation] {
        let response: APIResponse<[Conversation]> = try await NetworkManager.shared.request(endpoint: "/conversations")
        return response.data ?? []
    }
    
    func fetchMessages(conversationId: String) async throws -> [Message] {
        let response: APIResponse<[Message]> = try await NetworkManager.shared.request(endpoint: "/conversations/\(conversationId)/messages")
        return response.data ?? []
    }
    
    func sendMessage(conversationId: String, content: String) async throws -> Message {
        let body = ["content": content]
        let data = try JSONEncoder().encode(body)
        let response: APIResponse<Message> = try await NetworkManager.shared.request(
            endpoint: "/conversations/\(conversationId)/messages",
            method: "POST",
            body: data
        )
        guard let message = response.data else { throw NetworkError.unknown }
        return message
    }
}
