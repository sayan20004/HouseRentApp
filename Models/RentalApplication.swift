//
//  RentalApplication.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import SwiftUI // Changed from Foundation to SwiftUI to support Color

enum ApplicationStatus: String, Codable {
    case pending
    case shortlisted
    case accepted
    case rejected
    case cancelled
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .shortlisted: return .blue
        case .accepted: return .green
        case .rejected: return .red
        case .cancelled: return .gray
        }
    }
}

struct RentalApplication: Codable, Identifiable {
    let _id: String
    let property: PropertySummary
    let message: String
    let status: ApplicationStatus
    let monthlyRentOffered: Int?
    let moveInDate: String
    
    var id: String { _id }
}
