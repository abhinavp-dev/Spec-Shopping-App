//
//  SessionStore.swift
//  Spec-Shopping
//

import Foundation

/// App-wide observable session manager determining authentication state across screens.
@MainActor
@Observable
final class SessionStore {
    var isLoggedIn: Bool

    private let authRepository: AuthRepositoryProtocol

    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
        self.isLoggedIn = authRepository.hasActiveSession
    }

    /// Call when login completes successfully to update root routing.
    func loginCompleted() {
        isLoggedIn = true
    }

    /// Call on logout to clear session state.
    func logout() {
        isLoggedIn = false
    }
}
