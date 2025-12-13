//
//  AuthService.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    
    func login(email: String, password: String) async throws -> User {
        let body: [String: String] = ["email": email, "password": password]
        let data = try JSONEncoder().encode(body)
        
        let response: APIResponse<AuthData> = try await NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: data
        )
        
        if let authData = response.data {
            TokenManager.shared.save(token: authData.token)
            return authData.user
        }
        throw NetworkError.unknown
    }
    
    func register(name: String, email: String, phone: String, password: String, role: String) async throws -> User {
        let body: [String: String] = [
            "name": name,
            "email": email,
            "phone": phone,
            "password": password,
            "role": role
        ]
        let data = try JSONEncoder().encode(body)
        
        let response: APIResponse<AuthData> = try await NetworkManager.shared.request(
            endpoint: "/auth/register",
            method: "POST",
            body: data
        )
        
        if let authData = response.data {
            TokenManager.shared.save(token: authData.token)
            return authData.user
        }
        throw NetworkError.unknown
    }
    
    func fetchMe() async throws -> User {
        let response: APIResponse<User> = try await NetworkManager.shared.request(endpoint: "/auth/me")
        if let user = response.data {
            return user
        }
        throw NetworkError.unknown
    }
}
