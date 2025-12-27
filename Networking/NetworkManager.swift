import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .serverError(let msg): return msg
        case .unauthorized: return "Session expired. Please login again."
        default: return "Something went wrong. Please try again."
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Codable>(endpoint: String, method: String = "GET", body: Data? = nil, queryItems: [URLQueryItem]? = nil) async throws -> T {
        guard var urlComponents = URLComponents(string: APIConfig.baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        if httpResponse.statusCode == 401 {
            TokenManager.shared.clear()
            throw NetworkError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorResponse = try? JSONDecoder().decode(APIResponse<EmptyData>.self, from: data) {
                throw NetworkError.serverError(errorResponse.message ?? "Server error")
            }
            throw NetworkError.serverError("Error code: \(httpResponse.statusCode)")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func upload<T: Codable>(endpoint: String, method: String = "POST", parameters: [String: Any], images: [Data]) async throws -> T {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let token = TokenManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            
            if let dict = value as? [String: Any] {
                 let jsonData = try JSONSerialization.data(withJSONObject: dict)
                 let jsonString = String(data: jsonData, encoding: .utf8)!
                 body.append("\(jsonString)\r\n".data(using: .utf8)!)
            } else if let array = value as? [String] {
                 let jsonData = try JSONSerialization.data(withJSONObject: array)
                 let jsonString = String(data: jsonData, encoding: .utf8)!
                 body.append("\(jsonString)\r\n".data(using: .utf8)!)
            } else {
                 body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        for (index, imageData) in images.enumerated() {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.unknown }
        
        if !(200...299).contains(httpResponse.statusCode) {
             throw NetworkError.serverError("Upload failed: \(httpResponse.statusCode)")
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}
