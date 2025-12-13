//
//  ApplicationService.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation

class ApplicationService {
    static let shared = ApplicationService()
    
    func createApplication(propertyId: String, message: String, offer: Int?, date: Date) async throws {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)
        
        var body: [String: Any] = [
            "message": message,
            "moveInDate": dateString
        ]
        if let offer = offer {
            body["monthlyRentOffered"] = offer
        }
        
        let data = try JSONSerialization.data(withJSONObject: body)
        let _: APIResponse<RentalApplication> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(propertyId)/applications",
            method: "POST",
            body: data
        )
    }
    
    func fetchMyApplications(role: UserRole) async throws -> [RentalApplication] {
        let endpoint = role == .owner ? "/owner/applications" : "/applications/me"
        let response: APIResponse<[RentalApplication]> = try await NetworkManager.shared.request(endpoint: endpoint)
        return response.data ?? []
    }
}
