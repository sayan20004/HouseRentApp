//
//  PropertyDetailViewModel.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation
import Combine
@MainActor
class PropertyDetailViewModel: ObservableObject {
    let property: Property
    
    @Published var isSubmitting = false
    @Published var errorMsg: String?
    @Published var showSuccess = false
    
    init(property: Property) {
        self.property = property
    }
    
    func bookVisit(date: Date, notes: String) {
        isSubmitting = true
        Task {
            do {
                try await VisitService.shared.createVisit(propertyId: property.id, date: date, notes: notes)
                showSuccess = true
            } catch {
                errorMsg = error.localizedDescription
            }
            isSubmitting = false
        }
    }
    
    func applyForRent(message: String, offer: Int?, date: Date) {
        isSubmitting = true
        Task {
            do {
                try await ApplicationService.shared.createApplication(propertyId: property.id, message: message, offer: offer, date: date)
                showSuccess = true
            } catch {
                errorMsg = error.localizedDescription
            }
            isSubmitting = false
        }
    }
}
