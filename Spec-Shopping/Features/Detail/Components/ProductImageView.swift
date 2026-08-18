//
//  ProductImageView.swift
//  Spec-Shopping
//
//  Component for displaying product images with fallback placeholder and loading states.
//

import SwiftUI

struct ProductImageView: View {
    let imageURLString: String
    let title: String

    var body: some View {
        AsyncImage(url: URL(string: imageURLString)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.secondarySystemBackground)
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipShape(.rect(cornerRadius: 12))
                .accessibilityLabel("Loading product image for \(title)")

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 320)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    .accessibilityLabel("Product image for \(title)")

            case .failure:
                ZStack {
                    Color(.secondarySystemBackground)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.trianglebadge.exclamationmark")
                            .font(.system(size: 36))
                            .foregroundStyle(.secondary)
                        Text("Image Unavailable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(.rect(cornerRadius: 12))
                .accessibilityLabel("Image unavailable for \(title)")

            @unknown default:
                ZStack {
                    Color(.secondarySystemBackground)
                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipShape(.rect(cornerRadius: 12))
                .accessibilityLabel("Product image")
            }
        }
    }
}

#Preview("Success") {
    ProductImageView(
        imageURLString: "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png",
        title: "Essence Mascara"
    )
    .padding()
}

#Preview("Failure") {
    ProductImageView(
        imageURLString: "invalid-url",
        title: "Invalid Product"
    )
    .padding()
}
