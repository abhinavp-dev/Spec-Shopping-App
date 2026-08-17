//
//  User.swift
//  Spec-Shopping
//

import Foundation

/// Represents user profile data returned by DummyJSON auth API.
struct User: Codable, Identifiable, Equatable, Sendable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String?
    let image: String?

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
