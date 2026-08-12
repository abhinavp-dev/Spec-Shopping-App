//
//  APIClient.swift
//  Spec-Shopping
//

import Foundation

/// Strongly-typed network error model.
enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case unauthorized
    case server(statusCode: Int)
    case decodingFailed
    case network(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The requested URL is invalid."
        case .unauthorized:
            return "Invalid username or password."
        case .server(let statusCode):
            return "Server responded with error status: \(statusCode)."
        case .decodingFailed:
            return "Failed to decode response from server."
        case .network(let message):
            return message
        }
    }

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.unauthorized, .unauthorized),
             (.decodingFailed, .decodingFailed):
            return true
        case (.server(let lCode), .server(let rCode)):
            return lCode == rCode
        case (.network(let lMsg), .network(let rMsg)):
            return lMsg == rMsg
        default:
            return false
        }
    }
}

/// Generic URLSession API Client for constructing and executing network requests.
final class APIClient: Sendable {
    static let shared = APIClient()

    private let baseURLString = "https://dummyjson.com"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Executes an HTTP request and decodes the JSON payload into a strongly-typed model.
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURLString + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        if let body {
            request.httpBody = body
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.network("Invalid server response.")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }

        case 401:
            throw APIError.unauthorized

        default:
            throw APIError.server(statusCode: httpResponse.statusCode)
        }
    }
}
