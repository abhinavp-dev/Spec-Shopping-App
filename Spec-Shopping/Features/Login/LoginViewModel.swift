//
//  LoginViewModel.swift
//  Spec-Shopping
//

import Foundation

/// ViewModel managing state and authentication logic for LoginView.
@MainActor
@Observable
final class LoginViewModel {
    var username = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?

    private let authRepository: AuthRepositoryProtocol
    private let onLoginSuccess: () -> Void

    init(
        authRepository: AuthRepositoryProtocol = AuthRepository(),
        onLoginSuccess: @escaping () -> Void
    ) {
        self.authRepository = authRepository
        self.onLoginSuccess = onLoginSuccess
    }

    /// Client validation checking non-empty inputs.
    var isLoginButtonDisabled: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        isLoading
    }

    /// Triggers login authentication request against DummyJSON API.
    func login() async {
        guard !isLoginButtonDisabled else { return }

        isLoading = true
        errorMessage = nil

        do {
            _ = try await authRepository.login(
                username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                password: password.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            isLoading = false
            onLoginSuccess()
        } catch let error as APIError {
            isLoading = false
            errorMessage = error.localizedDescription
        } catch {
            isLoading = false
            errorMessage = "An unexpected error occurred. Please try again."
        }
    }

    /// Fills input fields with test credentials.
    func fillTestCredentials(user: String, pass: String) {
        username = user
        password = pass
        errorMessage = nil
    }
}
