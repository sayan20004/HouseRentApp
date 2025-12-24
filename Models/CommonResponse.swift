//
//  CommonResponse.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//
import Foundation

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
}

struct PaginatedResponse<T: Codable>: Codable {
    let success: Bool
    let data: [T]
    let pagination: PaginationMeta?
    let message: String?
}

struct PaginationMeta: Codable {
    let page: Int
    let limit: Int
    let totalPages: Int
    let totalItems: Int
    
    // Custom decoding to handle String or Int from API
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Helper to decode Int or String -> Int
        func decodeIntOrString(forKey key: CodingKeys) throws -> Int {
            if let intValue = try? container.decode(Int.self, forKey: key) {
                return intValue
            } else if let stringValue = try? container.decode(String.self, forKey: key),
                      let intValue = Int(stringValue) {
                return intValue
            }
            throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected Int or String for key \(key)"))
        }
        
        page = try decodeIntOrString(forKey: .page)
        limit = try decodeIntOrString(forKey: .limit)
        totalPages = try decodeIntOrString(forKey: .totalPages)
        totalItems = try decodeIntOrString(forKey: .totalItems)
    }
}

struct EmptyData: Codable {}
