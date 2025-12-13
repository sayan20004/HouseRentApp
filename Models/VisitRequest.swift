//
//  VisitRequest.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI // Changed from Foundation to SwiftUI to support Color

enum VisitStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case completed
    case cancelled
    
    var color: Color {
        switch self {
        case .pending: return .gray
        case .accepted: return .green
        case .rejected: return .red
        case .completed: return .blue
        case .cancelled: return .secondary
        }
    }
}

struct VisitRequest: Codable, Identifiable {
    let _id: String
    let property: PropertySummary
    let tenant: UserSummary?
    let owner: UserSummary?
    let preferredDateTime: String
    let status: VisitStatus
    let notes: String?
    
    var id: String { _id }
}

struct PropertySummary: Codable {
    let _id: String
    let title: String
    let location: Location?
    let rent: Int?
}

struct UserSummary: Codable {
    let _id: String
    let name: String
    let email: String
    let phone: String
}
