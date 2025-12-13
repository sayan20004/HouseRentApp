//
//  FavoriteService.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import Foundation

class FavoriteService {
    static let shared = FavoriteService()
    
    func fetchFavorites() async throws -> [Favorite] {
        let response: APIResponse<[Favorite]> = try await NetworkManager.shared.request(endpoint: "/favorites")
        return response.data ?? []
    }
    
    func addFavorite(propertyId: String) async throws {
        let _: APIResponse<Favorite> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(propertyId)/favorite",
            method: "POST"
        )
    }
    
    func removeFavorite(propertyId: String) async throws {
        let _: APIResponse<EmptyData> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(propertyId)/favorite",
            method: "DELETE"
        )
    }
}
