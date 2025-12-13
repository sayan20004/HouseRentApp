//
//  VisitsViewModel.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 13/12/25.
//

import Foundation
import SwiftUI
import Combine
@MainActor
class VisitsViewModel: ObservableObject {
    @Published var visits: [VisitRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func loadData(userRole: UserRole) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                visits = try await VisitService.shared.fetchMyVisits(role: userRole)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func updateVisitStatus(visitId: String, status: String, userRole: UserRole) {
        isLoading = true
        Task {
            do {
                try await VisitService.shared.updateStatus(id: visitId, status: status)
                loadData(userRole: userRole)
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
