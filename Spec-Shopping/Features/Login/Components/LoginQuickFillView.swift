//
//  LoginQuickFillView.swift
//  Spec-Shopping
//

import SwiftUI

/// Stage 1 helper panel with one-tap buttons for filling test credentials.
struct LoginQuickFillView: View {
    let onFillValid: () -> Void
    let onFillInvalid: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Text("Stage 1 Test Credentials")
                .font(.caption)
                .bold()
                .foregroundStyle(.secondary)

            Button(action: onFillValid) {
                Text("Use `emilys` / `emilyspass` (Valid)")
                    .font(.caption)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .foregroundStyle(Color.appPrimary)
                    .clipShape(.rect(cornerRadius: 8))
            }

            Button(action: onFillInvalid) {
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
}

#Preview {
    LoginQuickFillView(onFillValid: {}, onFillInvalid: {})
        .padding()
}
