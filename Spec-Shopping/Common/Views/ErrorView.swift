//
//  ErrorView.swift
//  Spec-Shopping
//

import SwiftUI

/// Shared error state view with a centered message and retry button.
struct ErrorView: View {
    let title: String
    let message: String
    let onRetry: () -> Void

    init(
        title: String = "Couldn't Load Products",
        message: String = "Please check your connection and try again.",
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onRetry) {
                Text("Retry")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(.rect(cornerRadius: 10))
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ErrorView(onRetry: {})
}
