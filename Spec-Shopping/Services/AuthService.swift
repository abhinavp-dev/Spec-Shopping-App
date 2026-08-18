//
//  AuthService.swift
//  Spec-Shopping
//

import Foundation

/// Protocol abstraction for Auth API operations.
protocol AuthServicing: Sendable {
    func login(username: String, password: String) async throws -> AuthResponse
}

/// Service handling authentication endpoints.
final class AuthService: AuthServicing, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func login(username: String, password: String) async throws -> AuthResponse {
        let payload: [String: Any] = [
            "username": username,
            "password": password,
            "expiresInMins": 60
        ]

        let bodyData = try JSONSerialization.data(withJSONObject: payload)

        return try await apiClient.request(
            endpoint: "/auth/login",
            method: "POST",
            body: bodyData
        )
    }
}
