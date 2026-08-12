//
//  HomeView.swift
//  Spec-Shopping
//

import SwiftUI

/// Main product catalog screen featuring navigation stack, pull-to-refresh, infinite scroll, and icon-only logout.
struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var selectedStubProduct: Product?

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
            .task {
                if viewModel.products.isEmpty {
                    await viewModel.fetchInitialProducts()
                }
            }
            .sheet(item: $selectedStubProduct) { product in
                detailStubSheet(product: product)
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
        .foregroundStyle(Color(hex: "D93025"))
        .accessibilityLabel("Log Out")
    }

    // MARK: - Product List Subview
    private var productList: some View {
        List {
            ForEach(viewModel.products) { product in
                Button(action: { selectedStubProduct = product }) {
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

    // MARK: - Stage 2 Detail Stub Sheet
    private func detailStubSheet(product: Product) -> some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text("STAGE 2 DETAIL ROUTE STUB")
                .font(.caption2)
                .bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(hex: "1D9E75").opacity(0.15))
                .foregroundStyle(Color(hex: "1D9E75"))
                .clipShape(.rect(cornerRadius: 6))

            AsyncImage(url: URL(string: product.thumbnail)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 160)
                        .clipShape(.rect(cornerRadius: 12))
                } else {
                    Color(.secondarySystemBackground)
                        .frame(height: 160)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }

            Text(product.title)
                .font(.title3)
                .bold()
                .foregroundStyle(.primary)

            HStack {
                Text(product.formattedPrice)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color(hex: "1D9E75"))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color(hex: "F5A623"))
                    Text(String(format: "%.2f", product.rating))
                        .bold()
                }
                .font(.subheadline)
            }
            .padding(.horizontal)

            Text(product.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Text("ℹ️ Navigation target verified per FR-2.9 — Detail screen view implementation deferred to Stage 2.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Spacer()

            Button("Close Preview") {
                selectedStubProduct = nil
            }
            .font(.headline)
            .bold()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(hex: "1D9E75"))
            .clipShape(.rect(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    HomeView(onLogout: {})
}
