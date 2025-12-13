//
//  User.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case tenant
    case owner
    case admin
}

struct User: Codable, Identifiable {
    let _id: String
    let name: String
    let email: String
    let phone: String
    let role: UserRole
    let isEmailVerified: Bool
    let createdAt: String
    
    var id: String { _id }
}

struct AuthData: Codable {
    let user: User
    let token: String
}
