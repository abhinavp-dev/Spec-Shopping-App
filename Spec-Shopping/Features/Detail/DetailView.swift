//
//  DetailView.swift
//  Spec-Shopping
//
//  Product Detail Screen displaying full product information, image, rating, price, and description.
//

import SwiftUI

struct DetailView: View {
    @State private var viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(productID: Int, initialProduct: Product? = nil, productService: ProductServicing = ProductService()) {
        _viewModel = State(initialValue: DetailViewModel(
            productID: productID,
            initialProduct: initialProduct,
            productService: productService
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.product == nil {
                LoadingView(title: "Loading Details", message: "Fetching product information...")
            } else if viewModel.isNotFound {
                notFoundView
            } else if let errorMessage = viewModel.errorMessage, viewModel.product == nil {
                ErrorView(message: errorMessage) {
                    Task { await viewModel.retry() }
                }
            } else if let product = viewModel.product {
                productDetailContent(product: product)
            } else {
                notFoundView
            }
        }
        .navigationTitle(viewModel.product?.title ?? "Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.product == nil {
                await viewModel.fetchProductDetail()
            }
        }
    }

    // MARK: - Product Detail Scroll Content
    private func productDetailContent(product: Product) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ProductImageView(
                    imageURLString: product.thumbnail,
                    title: product.title
                )

                ProductTitleView(
                    title: product.title,
                    brand: product.brand,
                    category: product.category
                )

                ProductRatingView(
                    rating: product.rating,
                    stock: product.stock
                )

                ProductPriceView(
                    formattedPrice: product.formattedPrice,
                    discountPercentage: product.discountPercentage
                )

                Divider()
                    .padding(.vertical, 4)

                ProductDescriptionView(
                    description: product.description
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.fetchProductDetail()
        }
    }

    // MARK: - Not Found View Fallback
    private var notFoundView: some View {
        ContentUnavailableView {
            Label("Product Not Found", systemImage: "square.slash")
        } description: {
            Text("The product you are looking for does not exist or has been removed.")
        } actions: {
            Button("Back to Catalog") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.appPrimary)
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        DetailView(
            productID: 1,
            initialProduct: Product(
                id: 1,
                title: "Essence Mascara Lash Princess",
                description: "The Essence Mascara Lash Princess is a popular mascara known for its volume and lengthening effects.",
                category: "beauty",
                price: 9.99,
                discountPercentage: 7.17,
                rating: 4.94,
                stock: 5,
                brand: "Essence",
                thumbnail: "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png",
                images: nil
            )
        )
    }
}

#Preview("Not Found") {
    NavigationStack {
        DetailView(productID: 999999)
    }
}
