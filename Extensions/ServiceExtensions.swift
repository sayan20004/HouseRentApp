//
//  ServiceExtensions.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import Foundation

extension PropertyService {
    func createProperty(_ input: PropertyInput) async throws {
        let data = try JSONEncoder().encode(input)
        let _: APIResponse<Property> = try await NetworkManager.shared.request(
            endpoint: "/properties",
            method: "POST",
            body: data
        )
    }
    
    func deleteProperty(id: String) async throws {
        let _: APIResponse<EmptyData> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(id)",
            method: "DELETE"
        )
    }
}

extension VisitService {
    func updateStatus(id: String, status: String) async throws {
        let body = ["status": status]
        let data = try JSONEncoder().encode(body)
        let _: APIResponse<VisitRequest> = try await NetworkManager.shared.request(
            endpoint: "/visit-requests/\(id)",
            method: "PATCH",
            body: data
        )
    }
}

extension ApplicationService {
    func updateStatus(id: String, status: String) async throws {
        let body = ["status": status]
        let data = try JSONEncoder().encode(body)
        let _: APIResponse<RentalApplication> = try await NetworkManager.shared.request(
            endpoint: "/applications/\(id)",
            method: "PATCH",
            body: data
        )
    }
}

extension AuthService {
    func updateProfile(name: String, phone: String) async throws -> User {
        let body = ["name": name, "phone": phone]
        let data = try JSONEncoder().encode(body)
        let response: APIResponse<User> = try await NetworkManager.shared.request(
            endpoint: "/users/me",
            method: "PATCH",
            body: data
        )
        guard let user = response.data else { throw NetworkError.unknown }
        return user
    }
    
    func convertToOwner() async throws -> User {
        let body = ["confirmRole": "owner"]
        let data = try JSONEncoder().encode(body)
        let response: APIResponse<User> = try await NetworkManager.shared.request(
            endpoint: "/users/me/role",
            method: "PATCH",
            body: data
        )
        guard let user = response.data else { throw NetworkError.unknown }
        return user
    }
}
