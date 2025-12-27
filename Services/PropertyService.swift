import Foundation

struct PropertyFilter {
    var city: String?
    var minRent: Int?
    var maxRent: Int?
    var bhk: Int?
    var furnishing: String?
    var allowedTenants: String?
    var propertyType: String?
    var petsAllowed: Bool?
    var sort: String?
    
    func toQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let city = city, !city.isEmpty { items.append(URLQueryItem(name: "city", value: city)) }
        if let min = minRent { items.append(URLQueryItem(name: "minRent", value: String(min))) }
        if let max = maxRent { items.append(URLQueryItem(name: "maxRent", value: String(max))) }
        if let bhk = bhk { items.append(URLQueryItem(name: "bhk", value: String(bhk))) }
        if let furnishing = furnishing { items.append(URLQueryItem(name: "furnishing", value: furnishing)) }
        if let tenants = allowedTenants { items.append(URLQueryItem(name: "allowedTenants", value: tenants)) }
        if let type = propertyType { items.append(URLQueryItem(name: "propertyType", value: type)) }
        if let pets = petsAllowed, pets { items.append(URLQueryItem(name: "petsAllowed", value: "true")) }
        if let sort = sort { items.append(URLQueryItem(name: "sortBy", value: sort)) }
        return items
    }
}

class PropertyService {
    static let shared = PropertyService()
    
    func fetchProperties(filter: PropertyFilter, page: Int = 1) async throws -> [Property] {
        var queryItems = filter.toQueryItems()
        queryItems.append(URLQueryItem(name: "page", value: String(page)))
        queryItems.append(URLQueryItem(name: "limit", value: "20"))
        
        let response: PaginatedResponse<Property> = try await NetworkManager.shared.request(
            endpoint: "/properties",
            queryItems: queryItems
        )
        return response.data
    }
    
    func fetchOwnerProperties() async throws -> [Property] {
        let response: APIResponse<[Property]> = try await NetworkManager.shared.request(endpoint: "/owner/properties")
        return response.data ?? []
    }
    
    func deleteProperty(id: String) async throws {
        let _: APIResponse<EmptyData> = try await NetworkManager.shared.request(
            endpoint: "/properties/\(id)",
            method: "DELETE"
        )
    }
    
    func updatePropertyStatus(id: String, status: String) async throws {
        let body = ["status": status]
        let data = try JSONEncoder().encode(body)
        let _: APIResponse<Property> = try await NetworkManager.shared.request(endpoint: "/properties/\(id)", method: "PATCH", body: data)
    }
    
    func createProperty(_ input: PropertyInput, imagesData: [Data]) async throws {
        var params: [String: Any] = [
            "title": input.title,
            "description": input.description,
            "propertyType": input.propertyType,
            "bhk": input.bhk,
            "furnishing": input.furnishing,
            "rent": input.rent,
            "securityDeposit": input.securityDeposit,
            "builtUpArea": input.builtUpArea,
            "availableFrom": input.availableFrom,
            "allowedTenants": input.allowedTenants,
            "amenities": input.amenities,
            "maintenance": [
                "amount": input.maintenance?.amount ?? 0,
                "included": input.maintenance?.included ?? false
            ]
        ]
        
        var locationDict: [String: Any] = [
            "city": input.location.city,
            "area": input.location.area,
            "pincode": input.location.pincode
        ]
        
        if let geo = input.location.geo {
            locationDict["geo"] = [
                "lat": geo.lat,
                "lng": geo.lng
            ]
        }
        
        params["location"] = locationDict

        let _: APIResponse<Property> = try await NetworkManager.shared.upload(
            endpoint: "/properties",
            method: "POST",
            parameters: params,
            images: imagesData
        )
    }
}
