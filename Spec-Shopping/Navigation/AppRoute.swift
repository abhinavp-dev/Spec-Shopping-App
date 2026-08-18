//
//  AppRoute.swift
//  Spec-Shopping
//

import Foundation

/// Navigation destinations for NavigationStack.
enum AppRoute: Hashable, Identifiable {
    case detail(productID: Int)

    var id: String {
        switch self {
        case .detail(let productID):
            return "detail_\(productID)"
        }
    }
}
