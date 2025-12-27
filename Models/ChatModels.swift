//
//  ChatModels.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import Foundation

struct Conversation: Codable, Identifiable {
    let _id: String
    let participants: [UserSummary]
    let property: PropertySummary
    let lastMessage: String
    let lastMessageAt: String
    
    var id: String { _id }
    
    func otherParticipant(myId: String) -> UserSummary? {
        return participants.first(where: { $0._id != myId })
    }
}

struct Message: Codable, Identifiable {
    let _id: String
    let conversation: String
    let sender: UserSummary
    let content: String
    let createdAt: String
    
    var id: String { _id }
}
