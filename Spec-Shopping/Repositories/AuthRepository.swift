//
//  AuthRepository.swift
//  Spec-Shopping
//

import Foundation

/// Protocol defining authentication persistence and session actions.
protocol AuthRepositoryProtocol: Sendable {
    var hasActiveSession: Bool { get }
    func login(username: String, password: String) async throws -> User
    func logout() throws
}

/// Repository coordinating AuthService network calls and Keychain storage.
final class AuthRepository: AuthRepositoryProtocol, Sendable {
    private let authService: AuthServicing
    private let keychainStore: KeychainStore
    private let tokenKey = "shoplite_access_token"

    init(
        authService: AuthServicing = AuthService(),
        keychainStore: KeychainStore = .shared
    ) {
        self.authService = authService
        self.keychainStore = keychainStore
    }

    /// Checks whether an access token exists in Keychain.
    var hasActiveSession: Bool {
        do {
            let token = try keychainStore.read(forKey: tokenKey)
            return !token.isEmpty
        } catch {
            return false
        }
    }

    /// Logs in user via API and persists access token to Keychain on success.
    func login(username: String, password: String) async throws -> User {
        let authResponse = try await authService.login(username: username, password: password)
        try keychainStore.save(authResponse.accessToken, forKey: tokenKey)
        return authResponse.toUser
    }

    /// Deletes session token from Keychain on logout.
    func logout() throws {
        try keychainStore.delete(forKey: tokenKey)
    }
}
