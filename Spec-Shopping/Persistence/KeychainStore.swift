//
//  KeychainStore.swift
//  Spec-Shopping
//

import Foundation
import Security

/// Strongly-typed error enum for Keychain operations.
enum KeychainError: Error, LocalizedError, Equatable {
    case duplicateItem
    case itemNotFound
    case unexpectedStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case .duplicateItem:
            return "Item already exists in Keychain."
        case .itemNotFound:
            return "Item not found in Keychain."
        case .unexpectedStatus(let status):
            return "Keychain operation failed with status code: \(status)."
        }
    }
}

/// Thin, thread-safe Keychain manager using the iOS Security framework.
final class KeychainStore: Sendable {
    static let shared = KeychainStore()

    private let serviceName = "com.shoplite.app.session"

    private init() {}

    /// Saves or updates a string value in the Keychain for a specific key.
    func save(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // First attempt to delete any existing item for this key
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    /// Reads a string value from the Keychain for a specific key.
    func read(forKey key: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = dataTypeRef as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.itemNotFound
        }

        return string
    }

    /// Deletes a value from the Keychain for a specific key.
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
