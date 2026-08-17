//
//  LoginErrorBannerView.swift
//  Spec-Shopping
//

import SwiftUI

/// Inline error banner shown above the login form when authentication or network failure occurs.
struct LoginErrorBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.appError)

            Text(message)
                .font(.footnote)
                .bold()
                .foregroundStyle(Color.appError)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(12)
        .background(Color.appError.opacity(0.12))
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appError.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    LoginErrorBannerView(message: "Invalid username or password.")
        .padding()
}
