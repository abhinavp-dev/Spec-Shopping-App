//
//  Product.swift
//  Spec-Shopping
//

import Foundation

/// Represents a product item returned by DummyJSON GET /products.
struct Product: Codable, Identifiable, Hashable, Equatable, Sendable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double?
    let rating: Double
    let stock: Int?
    let brand: String?
    let thumbnail: String
    let images: [String]?

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
}
