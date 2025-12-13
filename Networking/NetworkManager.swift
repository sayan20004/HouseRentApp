
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
        // Ensure APIConfig.baseURL is defined in your Config file.
        // If not, replace APIConfig.baseURL with your actual string URL.
        guard var urlComponents = URLComponents(string: "https://houserentapi.onrender.com/api/v1" + endpoint) else {
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
            print("Decoding error: \(error)")
            throw NetworkError.decodingError
        }
    }
}
