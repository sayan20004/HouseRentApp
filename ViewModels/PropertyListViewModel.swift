import Foundation
import Combine

enum QuickFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case apartment = "Apartment"
    case house = "House"
    case pg = "PG"
    case studio = "Studio"
    
    var id: String { self.rawValue }
    
    // Correctly maps UI names to your Backend Enums
    var propertyType: PropertyType? {
        switch self {
        case .all: return nil
        case .apartment: return .apartment
        case .house: return .independent_house // FIX: Maps "House" to "independent_house"
        case .pg: return .pg
        case .studio: return .studio
        }
    }
}

@MainActor
class PropertyListViewModel: ObservableObject {
    @Published var properties: [Property] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Search & Filter States
    @Published var searchText: String = ""
    @Published var selectedQuickFilter: QuickFilter = .all
    
    // Detailed Filters
    @Published var minRent: String = ""
    @Published var maxRent: String = ""
    @Published var selectedBHK: Int? = nil
    @Published var propertyType: PropertyType? = nil
    @Published var furnishing: Furnishing? = nil
    @Published var allowedTenants: AllowedTenants? = nil
    @Published var petsAllowed: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Debounce search to prevent too many API calls
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    func loadInitial() {
        fetch(reset: true)
    }
    
    func applyFilters() {
        fetch(reset: true)
    }
    
    func selectQuickFilter(_ filter: QuickFilter) {
        selectedQuickFilter = filter
        self.propertyType = filter.propertyType
        applyFilters()
    }
    
    private func fetch(reset: Bool) {
        isLoading = true
        errorMessage = nil
        
        var filter = PropertyFilter()
        
        // Search text maps to city
        if !searchText.isEmpty { filter.city = searchText }
        
        if let min = Int(minRent) { filter.minRent = min }
        if let max = Int(maxRent) { filter.maxRent = max }
        filter.bhk = selectedBHK
        
        // Use propertyType if set (by QuickFilter or FilterSheet)
        filter.propertyType = propertyType?.rawValue
        
        filter.furnishing = furnishing?.rawValue
        filter.allowedTenants = allowedTenants?.rawValue
        if petsAllowed { filter.petsAllowed = true }
        
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
                print("Error fetching properties: \(error)")
            }
            isLoading = false
        }
    }
}
