//
//  ReviewService.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 27/12/25.
//

import Foundation

class ReviewService {
    static let shared = ReviewService()
    
    func fetchReviews(propertyId: String) async throws -> [Review] {
        let response: APIResponse<[Review]> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(propertyId)/reviews"
        )
        return response.data ?? []
    }
    
    func submitReview(propertyId: String, rating: Int, comment: String) async throws {
        let body: [String: Any] = [
            "propertyId": propertyId,
            "rating": rating,
            "comment": comment
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        let _: APIResponse<Review> = try await NetworkManager.shared.request(
            endpoint: "/reviews",
            method: "POST",
            body: data
        )
    }
}
