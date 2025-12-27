import Foundation

struct MaintenanceInput: Encodable {
    let amount: Int
    let included: Bool
}

struct GeoInput: Encodable {
    let lat: Double
    let lng: Double
}

struct LocationInput: Encodable {
    let city: String
    let area: String
    let pincode: String
    let geo: GeoInput?
}

struct PropertyInput: Encodable {
    let title: String
    let description: String
    let propertyType: String
    let bhk: Int
    let furnishing: String
    let rent: Int
    let securityDeposit: Int
    let maintenance: MaintenanceInput?
    let builtUpArea: Int
    let availableFrom: String
    let location: LocationInput
    let amenities: [String]
    let images: [String]
    let allowedTenants: String
}
