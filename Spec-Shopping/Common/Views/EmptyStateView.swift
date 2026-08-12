//
//  EmptyStateView.swift
//  Spec-Shopping
//

import SwiftUI

/// Shared empty state view using native ContentUnavailableView.
struct EmptyStateView: View {
    let title: String
    let description: String
    let systemImage: String

    init(
        title: String = "No Products Found",
        description: String = "The product catalog is currently empty.",
        systemImage: String = "tray"
    ) {
        self.title = title
        self.description = description
        self.systemImage = systemImage
    }

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: systemImage,
            description: Text(description)
        )
    }
}

#Preview {
    EmptyStateView()
}
