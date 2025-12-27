import Foundation

enum PropertyType: String, Codable, CaseIterable, Identifiable {
    case apartment
    case independent_house
    case pg
    case studio
    case shared_flat
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

enum Furnishing: String, Codable, CaseIterable, Identifiable {
    case unfurnished
    case semi_furnished
    case fully_furnished
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

enum AllowedTenants: String, Codable, CaseIterable, Identifiable {
    case family
    case bachelors
    case students
    case any
    
    var id: String { rawValue }
    
    var displayName: String { rawValue.capitalized }
}

struct GeoLocation: Codable {
    let lat: Double
    let lng: Double
}

struct Location: Codable {
    let city: String
    let area: String
    let landmark: String?
    let pincode: String
    let geo: GeoLocation?
}

struct Maintenance: Codable {
    let amount: Int
    let included: Bool
}

struct PropertyOwnerSummary: Codable {
    let _id: String
    let name: String
    let email: String
    let phone: String
}

struct Property: Codable, Identifiable {
    let _id: String
    let owner: PropertyOwnerSummary
    let title: String
    let description: String
    let propertyType: PropertyType
    let bhk: Int
    let furnishing: Furnishing
    let rent: Int
    let securityDeposit: Int
    let maintenance: Maintenance?
    let builtUpArea: Int
    let availableFrom: String
    let allowedTenants: AllowedTenants
    let petsAllowed: Bool
    let smokingAllowed: Bool
    let location: Location
    let amenities: [String]
    let images: [String]
    let isVerified: Bool
    let status: String
    
    var id: String { _id }
}
