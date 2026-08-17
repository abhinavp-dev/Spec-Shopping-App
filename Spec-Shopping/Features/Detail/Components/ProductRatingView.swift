//
//  ProductRatingView.swift
//  Spec-Shopping
//
//  Component for displaying product rating stars, numerical rating, and stock indicator.
//

import SwiftUI

struct ProductRatingView: View {
    let rating: Double
    let stock: Int?

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(Color.appWarning)

                Text(String(format: "%.2f", rating))
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Rating: \(String(format: "%.2f", rating)) out of 5 stars")

            if let stock = stock {
                Text("•")
                    .foregroundStyle(.tertiary)

                HStack(spacing: 4) {
                    Image(systemName: stock > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(stock > 0 ? .green : Color.appError)

                    Text(stock > 0 ? "\(stock) in stock" : "Out of stock")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(stock > 0 ? "\(stock) items in stock" : "Out of stock")
            }

            Spacer()
        }
    }
}

#Preview("In Stock") {
    ProductRatingView(rating: 4.94, stock: 14)
        .padding()
}

#Preview("Out of Stock") {
    ProductRatingView(rating: 3.50, stock: 0)
        .padding()
}
