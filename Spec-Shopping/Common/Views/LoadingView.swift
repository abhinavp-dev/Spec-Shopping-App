//
//  LoadingView.swift
//  Spec-Shopping
//

import SwiftUI

/// Shared loading state view displaying a centered ProgressView and status text.
struct LoadingView: View {
    let title: String
    let message: String?

    init(title: String = "Loading...", message: String? = nil) {
        self.title = title
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.accentColor)

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    LoadingView(title: "Loading Products", message: "Fetching latest catalog items...")
}
