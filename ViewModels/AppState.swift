//
//  AppState.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoadingUser = true
    
    init() {
        checkSession()
    }
    
    func checkSession() {
        if TokenManager.shared.getToken() != nil {
            Task {
                do {
                    let user = try await AuthService.shared.fetchMe()
                    self.currentUser = user
                } catch {
                    logout()
                }
                self.isLoadingUser = false
            }
        } else {
            isLoadingUser = false
        }
    }
    
    func logout() {
        TokenManager.shared.clear()
        currentUser = nil
    }
}
