//
//  LoginView.swift
//  Spec-Shopping
//

import SwiftUI

/// Login screen rendering brand header, credential inputs, inline error banner, and quick-fill helpers.
struct LoginView: View {
    @State private var viewModel: LoginViewModel
    @State private var isPasswordVisible = false

    init(onLoginSuccess: @escaping () -> Void) {
        _viewModel = State(initialValue: LoginViewModel(onLoginSuccess: onLoginSuccess))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView

                if let errorMessage = viewModel.errorMessage {
                    errorBannerView(errorMessage: errorMessage)
                }

                formView

                quickFillView
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    // MARK: - Header Subview
    private var headerView: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "1D9E75"), Color(hex: "107052")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: Color(hex: "1D9E75").opacity(0.3), radius: 10, x: 0, y: 6)

                Image(systemName: "bag.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }

            Text("ShopLite")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.primary)

            Text("Sign in to your e-commerce account")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Error Banner Subview
    private func errorBannerView(errorMessage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color(hex: "D93025"))

            Text(errorMessage)
                .font(.footnote)
                .bold()
                .foregroundStyle(Color(hex: "D93025"))
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(12)
        .background(Color(hex: "D93025").opacity(0.12))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "D93025").opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Credentials Form
    private var formView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Username")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)

                TextField("e.g. emilys", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)

                HStack {
                    if isPasswordVisible {
                        TextField("Enter password", text: $viewModel.password)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("Enter password", text: $viewModel.password)
                    }

                    Button(action: { isPasswordVisible.toggle() }) {
                        Text(isPasswordVisible ? "Hide" : "Show")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 12))
            }

            Button(action: handleLoginTap) {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Log In")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "1D9E75"))
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
                .opacity(viewModel.isLoginButtonDisabled ? 0.5 : 1.0)
            }
            .disabled(viewModel.isLoginButtonDisabled)
            .padding(.top, 8)
        }
    }

    // MARK: - Quick Fill Helpers
    private var quickFillView: some View {
        VStack(spacing: 10) {
            Text("Stage 1 Test Credentials")
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)

            Button(action: {
                viewModel.fillTestCredentials(user: "emilys", pass: "emilyspass")
            }) {
                Text("Use `emilys` / `emilyspass` (Valid)")
                    .font(.caption)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .foregroundStyle(Color(hex: "1D9E75"))
                    .clipShape(.rect(cornerRadius: 8))
            }

            Button(action: {
                viewModel.fillTestCredentials(user: "wronguser", pass: "wrongpass")
            }) {
                Text("Use Invalid Credentials (401 Error)")
                    .font(.caption)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .foregroundStyle(.secondary)
                    .clipShape(.rect(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.top, 16)
    }

    // MARK: - Actions
    private func handleLoginTap() {
        Task {
            await viewModel.login()
        }
    }
}

// MARK: - Color Hex Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    LoginView(onLoginSuccess: {})
}
