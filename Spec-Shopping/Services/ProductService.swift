//
//  ProductService.swift
//  Spec-Shopping
//

import Foundation

/// Protocol abstraction for Product API operations.
protocol ProductServicing: Sendable {
    func fetchProducts(limit: Int, skip: Int) async throws -> ProductsResponse
}

/// Service handling product catalog API endpoints.
final class ProductService: ProductServicing, Sendable {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchProducts(limit: Int, skip: Int) async throws -> ProductsResponse {
        let endpoint = "/products?limit=\(limit)&skip=\(skip)"
        return try await apiClient.request(endpoint: endpoint, method: "GET")
    }
}
