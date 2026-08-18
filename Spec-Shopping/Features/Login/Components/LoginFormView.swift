//
//  LoginFormView.swift
//  Spec-Shopping
//

import SwiftUI

/// Username/password credential form and Log In button for the Login screen.
struct LoginFormView: View {
    @Bindable var viewModel: LoginViewModel
    @Binding var isPasswordVisible: Bool
    let onLoginTap: () -> Void

    var body: some View {
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

            Button(action: onLoginTap) {
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
                .background(Color.appPrimary)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 10))
                .opacity(viewModel.isLoginButtonDisabled ? 0.5 : 1.0)
            }
            .disabled(viewModel.isLoginButtonDisabled)
            .padding(.top, 8)
        }
    }
}

#Preview {
    LoginFormView(
        viewModel: LoginViewModel(onLoginSuccess: {}),
        isPasswordVisible: .constant(false),
        onLoginTap: {}
    )
    .padding()
}
