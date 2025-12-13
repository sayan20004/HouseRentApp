//
//  VisitService.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation

class VisitService {
    static let shared = VisitService()
    
    func createVisit(propertyId: String, date: Date, notes: String?) async throws {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        let body: [String: Any] = [
            "preferredDateTime": dateString,
            "notes": notes ?? ""
        ]
        let data = try JSONSerialization.data(withJSONObject: body)
        
        let _: APIResponse<VisitRequest> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(propertyId)/visit-requests",
            method: "POST",
            body: data
        )
    }
    
    func fetchMyVisits(role: UserRole) async throws -> [VisitRequest] {
        let endpoint = role == .owner ? "/owner/visit-requests" : "/visit-requests/me"
        let response: APIResponse<[VisitRequest]> = try await NetworkManager.shared.request(endpoint: endpoint)
        return response.data ?? []
    }
}
