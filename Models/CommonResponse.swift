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
}

struct EmptyData: Codable {}
