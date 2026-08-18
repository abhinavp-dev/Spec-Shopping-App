//
//  HomeViewModel.swift
//  Spec-Shopping
//

import Foundation

/// ViewModel managing state, pagination, and product list logic for HomeView.
@MainActor
@Observable
final class HomeViewModel {
    var products: [Product] = []
    var isLoadingInitial = false
    var isLoadingMore = false
    var errorMessage: String?
    var hasMorePages = true

    private var skip = 0
    private let limit = 10
    private var totalProducts = 0

    private let productService: ProductServicing
    private let authRepository: AuthRepositoryProtocol
    private let onLogout: () -> Void

    init(
        productService: ProductServicing = ProductService(),
        authRepository: AuthRepositoryProtocol = AuthRepository(),
        onLogout: @escaping () -> Void
    ) {
        self.productService = productService
        self.authRepository = authRepository
        self.onLogout = onLogout
    }

    /// Fetches initial page of products (or resets on pull-to-refresh).
    func fetchInitialProducts() async {
        guard !isLoadingInitial else { return }

        isLoadingInitial = true
        errorMessage = nil
        skip = 0
        hasMorePages = true

        do {
            let response = try await productService.fetchProducts(limit: limit, skip: skip)
            products = response.products
            totalProducts = response.total
            skip += limit
            hasMorePages = skip < totalProducts
            isLoadingInitial = false
        } catch let error as APIError {
            isLoadingInitial = false
            errorMessage = error.localizedDescription
        } catch {
            isLoadingInitial = false
            errorMessage = "Failed to load products. Please try again."
        }
    }

    /// Fetches next page of products when scrolling near bottom of list.
    func fetchNextPage() async {
        guard !isLoadingInitial, !isLoadingMore, hasMorePages else { return }

        isLoadingMore = true

        do {
            let response = try await productService.fetchProducts(limit: limit, skip: skip)
            
            // Deduplicate items by product ID per Task Document edge case rules
            let existingIDs = Set(products.map(\.id))
            let newUniqueProducts = response.products.filter { !existingIDs.contains($0.id) }
            
            products.append(contentsOf: newUniqueProducts)
            totalProducts = response.total
            skip += limit
            hasMorePages = skip < totalProducts
            isLoadingMore = false
        } catch {
            isLoadingMore = false
            // Keep existing products visible, silent inline retry on next scroll
        }
    }

    /// Triggers user logout and clears session state.
    func logout() {
        do {
            try authRepository.logout()
        } catch {
            print("Keychain cleanup error: \(error.localizedDescription)")
        }
        onLogout()
    }
}
