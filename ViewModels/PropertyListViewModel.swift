//
//  PropertyListViewModel.swift
//  HouseRentClient
//
//  Created by Sayan  Maity  on 22/11/25.
//

import Foundation
import Combine
@MainActor
class PropertyListViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var city: String = ""
    @Published var minRent: String = ""
    @Published var maxRent: String = ""
    @Published var selectedBHK: Int? = nil
    
    func loadInitial() {
        fetch(reset: true)
    }
    
    func applyFilters() {
        fetch(reset: true)
    }
    
    private func fetch(reset: Bool) {
        isLoading = true
        errorMessage = nil
        
        var filter = PropertyFilter()
        if !city.isEmpty { filter.city = city }
        if let min = Int(minRent) { filter.minRent = min }
        if let max = Int(maxRent) { filter.maxRent = max }
        filter.bhk = selectedBHK
        
        Task {
            do {
                let items = try await PropertyService.shared.fetchProperties(filter: filter)
                if reset {
                    properties = items
                } else {
                    properties.append(contentsOf: items)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
