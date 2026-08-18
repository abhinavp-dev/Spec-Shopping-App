//
//  DetailViewModel.swift
//  Spec-Shopping
//
//  ViewModel for managing Product Detail Screen state and API calls.
//

import Foundation
import Observation

/// MainActor isolated ViewModel for managing product detail state.
@MainActor
@Observable
final class DetailViewModel {
    let productID: Int

    private(set) var product: Product?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isNotFound = false

    private let productService: ProductServicing

    init(
        productID: Int,
        initialProduct: Product? = nil,
        productService: ProductServicing? = nil
    ) {
        self.productID = productID
        self.product = initialProduct
        self.productService = productService ?? ProductService()
    }

    /// Fetches single product details by product ID.
    func fetchProductDetail() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        isNotFound = false

        do {
            let fetchedProduct = try await productService.fetchProduct(id: productID)
            self.product = fetchedProduct
            self.isLoading = false
        } catch let error as APIError {
            self.isLoading = false
            switch error {
            case .server(let code) where code == 404:
                self.isNotFound = true
            case .decodingFailed:
                self.isNotFound = true
            default:
                self.errorMessage = error.localizedDescription
            }
        } catch {
            self.isLoading = false
            if Task.isCancelled { return }
            self.errorMessage = error.localizedDescription
        }
    }

    /// Re-attempts fetching product detail after an error.
    func retry() async {
        await fetchProductDetail()
    }
}
