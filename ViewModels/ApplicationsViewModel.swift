//
//  ApplicationsViewModel.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import Foundation
import SwiftUI
import Combine
@MainActor
class ApplicationsViewModel: ObservableObject {
    @Published var applications: [RentalApplication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadData(userRole: UserRole) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                applications = try await ApplicationService.shared.fetchMyApplications(role: userRole)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func updateApplicationStatus(applicationId: String, status: String, userRole: UserRole) {
        isLoading = true
        Task {
            do {
                try await ApplicationService.shared.updateStatus(id: applicationId, status: status)
                loadData(userRole: userRole)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
