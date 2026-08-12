//
//  Spec_ShoppingTests.swift
//  Spec-ShoppingTests
//

import XCTest
@testable import Spec_Shopping

// MARK: - Mocks for Testing
final class MockAuthService: AuthServicing, @unchecked Sendable {
    var shouldFail = false
    var mockResponse = AuthResponse(
        id: 1,
        username: "emilys",
        email: "emilys@gmail.com",
        firstName: "Emily",
        lastName: "Smith",
        gender: "female",
        image: nil,
        accessToken: "mock_access_token_123",
        refreshToken: nil
    )

    func login(username: String, password: String) async throws -> AuthResponse {
        if shouldFail {
            throw APIError.unauthorized
        }
        return mockResponse
    }
}

final class MockProductService: ProductServicing, @unchecked Sendable {
    var shouldFail = false
    var mockProducts = [
        Product(id: 1, title: "Product 1", description: "Desc 1", category: "cat", price: 10.0, discountPercentage: nil, rating: 4.5, stock: 5, brand: "Brand A", thumbnail: "", images: nil),
        Product(id: 2, title: "Product 2", description: "Desc 2", category: "cat", price: 20.0, discountPercentage: nil, rating: 4.0, stock: 3, brand: "Brand B", thumbnail: "", images: nil)
    ]

    func fetchProducts(limit: Int, skip: Int) async throws -> ProductsResponse {
        if shouldFail {
            throw APIError.network("Network failure mock")
        }
        return ProductsResponse(products: mockProducts, total: 20, skip: skip, limit: limit)
    }
}

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var sessionActive = false
    var shouldFail = false

    var hasActiveSession: Bool {
        sessionActive
    }

    func login(username: String, password: String) async throws -> User {
        if shouldFail {
            throw APIError.unauthorized
        }
        sessionActive = true
        return User(id: 1, username: username, email: "test@test.com", firstName: "Test", lastName: "User", gender: nil, image: nil)
    }

    func logout() throws {
        sessionActive = false
    }
}

// MARK: - ViewModel Unit Tests
final class Spec_ShoppingTests: XCTestCase {

    @MainActor
    func testLoginValidationDisabledWhenEmpty() {
        let mockRepo = MockAuthRepository()
        let vm = LoginViewModel(authRepository: mockRepo, onLoginSuccess: {})

        XCTAssertTrue(vm.isLoginButtonDisabled, "Login button should be disabled when fields are empty")

        vm.username = "emilys"
        XCTAssertTrue(vm.isLoginButtonDisabled, "Login button should be disabled when password is empty")

        vm.password = "emilyspass"
        XCTAssertFalse(vm.isLoginButtonDisabled, "Login button should be enabled when both fields are filled")
    }

    @MainActor
    func testLoginSuccessFlow() async {
        let mockRepo = MockAuthRepository()
        var successCalled = false

        let vm = LoginViewModel(authRepository: mockRepo) {
            successCalled = true
        }

        vm.username = "emilys"
        vm.password = "emilyspass"

        await vm.login()

        XCTAssertTrue(successCalled, "onLoginSuccess callback should be called on successful login")
        XCTAssertNil(vm.errorMessage, "errorMessage should be nil on success")
        XCTAssertTrue(mockRepo.hasActiveSession, "Session should be active after login")
    }

    @MainActor
    func testLoginFailureFlow() async {
        let mockRepo = MockAuthRepository()
        mockRepo.shouldFail = true
        var successCalled = false

        let vm = LoginViewModel(authRepository: mockRepo) {
            successCalled = true
        }

        vm.username = "wronguser"
        vm.password = "wrongpass"

        await vm.login()

        XCTAssertFalse(successCalled, "onLoginSuccess callback should not be called on failure")
        XCTAssertNotNil(vm.errorMessage, "errorMessage should be set on failure")
        XCTAssertEqual(vm.errorMessage, "Invalid username or password.")
        XCTAssertFalse(mockRepo.hasActiveSession, "Session should remain inactive")
    }

    @MainActor
    func testHomeFetchInitialProductsSuccess() async {
        let mockService = MockProductService()
        let mockRepo = MockAuthRepository()
        let vm = HomeViewModel(productService: mockService, authRepository: mockRepo, onLogout: {})

        XCTAssertTrue(vm.products.isEmpty)

        await vm.fetchInitialProducts()

        XCTAssertEqual(vm.products.count, 2)
        XCTAssertEqual(vm.products.first?.title, "Product 1")
        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(vm.hasMorePages)
    }

    @MainActor
    func testHomeFetchInitialProductsFailure() async {
        let mockService = MockProductService()
        mockService.shouldFail = true
        let mockRepo = MockAuthRepository()
        let vm = HomeViewModel(productService: mockService, authRepository: mockRepo, onLogout: {})

        await vm.fetchInitialProducts()

        XCTAssertTrue(vm.products.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
    }
}
