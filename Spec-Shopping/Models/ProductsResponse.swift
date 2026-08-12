//
//  ProductsResponse.swift
//  Spec-Shopping
//

import Foundation

/// Response payload for GET /products pagination endpoint.
struct ProductsResponse: Codable, Equatable, Sendable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
