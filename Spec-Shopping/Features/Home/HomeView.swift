//
//  HomeView.swift
//  Spec-Shopping
//

import SwiftUI

/// Main product catalog screen featuring navigation stack, pull-to-refresh, infinite scroll, and icon-only logout.
struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(onLogout: @escaping () -> Void) {
        _viewModel = State(initialValue: HomeViewModel(onLogout: onLogout))
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoadingInitial && viewModel.products.isEmpty {
                    LoadingView(title: "Loading Products", message: "Fetching latest catalog items...")
                } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                    ErrorView(message: errorMessage) {
                        Task { await viewModel.fetchInitialProducts() }
                    }
                } else if viewModel.products.isEmpty {
                    EmptyStateView()
                } else {
                    productList
                }
            }
            .navigationTitle("Products")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    logoutButton
                }
            }
            .navigationDestination(for: Product.self) { product in
                DetailView(productID: product.id, initialProduct: product)
            }
            .task {
                if viewModel.products.isEmpty {
                    await viewModel.fetchInitialProducts()
                }
            }
        }
    }

    // MARK: - Icon-Only Logout Button
    private var logoutButton: some View {
        Button("Log Out", systemImage: "rectangle.portrait.and.arrow.right") {
            viewModel.logout()
        }
        .labelStyle(.iconOnly)
        .font(.body.weight(.semibold))
        .foregroundStyle(Color.appError)
        .accessibilityLabel("Log Out")
    }

    // MARK: - Product List Subview
    private var productList: some View {
        List {
            ForEach(viewModel.products) { product in
                NavigationLink(value: product) {
                    ProductRowView(product: product)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .onAppear {
                    if product == viewModel.products.last {
                        Task {
                            await viewModel.fetchNextPage()
                        }
                    }
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView("Loading more...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchInitialProducts()
        }
    }
}

#Preview {
    HomeView(onLogout: {})
}
