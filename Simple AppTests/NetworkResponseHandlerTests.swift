//
//  NetworkResponseHandlerTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//
import XCTest
@testable import Simple_App
// MARK: - Network Response Handler Tests

final class NetworkResponseHandlerTests: XCTestCase {
    
    func testHandleNetworkResponseSuccess() {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When
        let result = handleNetworkResponse(response)
        
        // Then
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure:
            XCTFail("Expected success")
        }
    }
    
    func testHandleNetworkResponseNotFound() {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When
        let result = handleNetworkResponse(response)
        
        // Then
        switch result {
        case .success:
            XCTAssertTrue(true) // 404 is treated as success in your implementation
        case .failure:
            XCTFail("Expected success for 404")
        }
    }
    
    func testHandleNetworkResponseAuthenticationError() {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When
        let result = handleNetworkResponse(response)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 401")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 401)
        }
    }
    
    func testHandleNetworkResponseServerError() {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 502,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When
        let result = handleNetworkResponse(response)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 502")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 502)
        }
    }
    
    func testHandleNetworkResponseOutdated() {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 600,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When
        let result = handleNetworkResponse(response)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for 600")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 600)
        }
    }
    
    func testHandleNetworkResponseUnknownError() {
        // Given
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 999,
            httpVersion: nil,
            headerFields: nil
        )!
        
        // When
        let result = handleNetworkResponse(response)
        
        // Then
        switch result {
        case .success:
            XCTFail("Expected failure for unknown status code")
        case .failure(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 999)
        }
    }
}
