//
//  AppRoute.swift
//  Spec-Shopping
//

import Foundation

/// Navigation destinations for NavigationStack.
enum AppRoute: Hashable, Identifiable {
    case detailStub(Product)

    var id: String {
        switch self {
        case .detailStub(let product):
            return "detail_\(product.id)"
        }
    }
}
