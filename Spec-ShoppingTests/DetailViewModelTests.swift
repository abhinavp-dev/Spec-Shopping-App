//
//  DetailViewModelTests.swift
//  Spec-ShoppingTests
//
//  Unit tests for DetailViewModel covering product fetch success, network error, and 404 not found states.
//

import XCTest
@testable import Spec_Shopping

final class DetailViewModelTests: XCTestCase {

    @MainActor
    func testFetchProductSuccess() async {
        let mockService = MockProductService()
        let vm = DetailViewModel(productID: 1, productService: mockService)

        XCTAssertNil(vm.product)
        XCTAssertFalse(vm.isLoading)

        await vm.fetchProductDetail()

        XCTAssertNotNil(vm.product)
        XCTAssertEqual(vm.product?.id, 1)
        XCTAssertEqual(vm.product?.title, "Product 1")
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isNotFound)
    }

    @MainActor
    func testFetchProductNetworkFailure() async {
        let mockService = MockProductService()
        mockService.shouldFail = true
        let vm = DetailViewModel(productID: 1, productService: mockService)

        await vm.fetchProductDetail()

        XCTAssertNil(vm.product)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isNotFound)
    }

    @MainActor
    func testFetchProductNotFound() async {
        let mockService = MockProductService()
        mockService.shouldReturnNotFound = true
        let vm = DetailViewModel(productID: 999, productService: mockService)

        await vm.fetchProductDetail()

        XCTAssertNil(vm.product)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertTrue(vm.isNotFound)
    }

    @MainActor
    func testRetryMechanism() async {
        let mockService = MockProductService()
        mockService.shouldFail = true
        let vm = DetailViewModel(productID: 1, productService: mockService)

        await vm.fetchProductDetail()
        XCTAssertNotNil(vm.errorMessage)

        mockService.shouldFail = false
        await vm.retry()

        XCTAssertNotNil(vm.product)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isNotFound)
    }
}
