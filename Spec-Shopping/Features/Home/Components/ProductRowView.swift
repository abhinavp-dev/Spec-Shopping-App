//
//  ProductRowView.swift
//  Spec-Shopping
//

import SwiftUI

/// Card row component rendering product thumbnail, title, brand, price, and star rating.
struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            thumbnailImage

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.body)
                    .bold()
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                if let brand = product.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(product.category.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text(product.formattedPrice)
                        .font(.callout)
                        .bold()
                        .foregroundStyle(Color(hex: "1D9E75"))

                    Spacer()

                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: "F5A623"))
                            .accessibilityHidden(true)

                        Text(String(format: "%.2f", product.rating))
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.title), \(product.formattedPrice), rating \(String(format: "%.1f", product.rating)) stars")
    }

    // MARK: - Thumbnail Image Subview
    private var thumbnailImage: some View {
        AsyncImage(url: URL(string: product.thumbnail)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 80, height: 80)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(.rect(cornerRadius: 10))

            case .failure:
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 80, height: 80)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(.rect(cornerRadius: 10))
                    .accessibilityHidden(true)

            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ProductRowView(
        product: Product(
            id: 1,
            title: "Essence Mascara Lash Princess",
            description: "A popular mascara.",
            category: "beauty",
            price: 9.99,
            discountPercentage: 7.17,
            rating: 4.94,
            stock: 5,
            brand: "Essence",
            thumbnail: "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png",
            images: nil
        )
    )
    .padding()
}
