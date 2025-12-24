//
//  PropertyInput.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import Foundation

struct MaintenanceInput: Encodable {
    let amount: Int
    let included: Bool
}

struct PropertyInput: Encodable {
    let title: String
    let description: String
    let propertyType: String
    let bhk: Int
    let furnishing: String
    let rent: Int
    let securityDeposit: Int
    let maintenance: MaintenanceInput?
    let builtUpArea: Int
    let availableFrom: String
    let location: Location
    let amenities: [String]
    let images: [String]
    let allowedTenants: String
}
