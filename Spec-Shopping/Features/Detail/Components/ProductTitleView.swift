//
//  ProductTitleView.swift
//  Spec-Shopping
//
//  Component for displaying product title, category, and brand badges.
//

import SwiftUI

struct ProductTitleView: View {
    let title: String
    let brand: String?
    let category: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(category.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.appPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appPrimary.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 6))

                if let brand = brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(.rect(cornerRadius: 6))
                }

                Spacer()
            }

            Text(title)
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHeading(.h1)
        }
    }
}

#Preview {
    ProductTitleView(
        title: "Essence Mascara Lash Princess",
        brand: "Essence",
        category: "beauty"
    )
    .padding()
}
