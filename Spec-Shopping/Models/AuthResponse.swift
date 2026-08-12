//
//  AuthResponse.swift
//  Spec-Shopping
//

import Foundation

/// Response payload returned by POST /auth/login.
struct AuthResponse: Codable, Equatable, Sendable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String?
    let image: String?
    let accessToken: String
    let refreshToken: String?

    var toUser: User {
        User(
            id: id,
            username: username,
            email: email,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            image: image
        )
    }
}
