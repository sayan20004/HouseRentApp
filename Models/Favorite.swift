//
//  Favorite.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import Foundation

struct Favorite: Codable, Identifiable {
    let _id: String
    let property: Property
    
    var id: String { _id }
}
