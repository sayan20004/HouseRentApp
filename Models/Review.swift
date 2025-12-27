//
//  Review.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import Foundation

struct Review: Codable, Identifiable {
    let _id: String
    let reviewer: UserSummary
    let rating: Int
    let comment: String?
    let createdAt: String
    
    var id: String { _id }
}
