//
//  ProductPriceView.swift
//  Spec-Shopping
//
//  Component for displaying product formatted currency price and discount badge.
//

import SwiftUI

struct ProductPriceView: View {
    let formattedPrice: String
    let discountPercentage: Double?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(formattedPrice)
                .font(.title)
                .bold()
                .foregroundStyle(Color.appPrimary)

            if let discount = discountPercentage, discount > 0 {
                Text("\(String(format: "%.0f", discount))% OFF")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appError)
                    .clipShape(.rect(cornerRadius: 6))
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(discountLabel)
    }

    private var discountLabel: String {
        if let discount = discountPercentage, discount > 0 {
            return "Price \(formattedPrice), \(String(format: "%.0f", discount)) percent discount"
        }
        return "Price \(formattedPrice)"
    }
}

#Preview("Standard") {
    ProductPriceView(formattedPrice: "$9.99", discountPercentage: 12.5)
        .padding()
}
