//
//  NetworkManagerTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//

import XCTest
@testable import Simple_App

final class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    var mockRouter: MockRouter!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
        mockRouter = MockRouter()
    }
    
    override func tearDown() {
        networkManager = nil
        mockRouter = nil
        super.tearDown()
    }
    
    // MARK: - Success Cases
    
    func testGetPicturesSuccess() async throws {
        // Given
        let mockPicturesJSON = """
        [
            {
                "id": "1",
                "author": "Alejandro Escamilla",
                "width": 4855,
                "height": 1803,
                "url": "https://unsplash.com/photos/cZhUxIQjILg",
                "download_url": "https://picsum.photos/id/24/4855/1803"
            },
            {
                "id": "2",
                "author": "Alejandro Escamilla",
                "width": 5000,
                "height": 3333,
                "url": "https://unsplash.com/photos/Iuq0EL4EINY",
                "download_url": "https://picsum.photos/id/25/5000/3333"
            }
        ]
        """.data(using: .utf8)!
        
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // Create a NetworkManager with dependency injection for testing
        let testableNetworkManager = TestableNetworkManager(
            mockData: mockPicturesJSON,
            mockResponse: mockResponse,
            mockError: nil
        )
        
        // When
        let pictures = try await testableNetworkManager.getPictures()
        
        // Then
        XCTAssertEqual(pictures.count, 2)
        XCTAssertEqual(pictures[0].id, "1")
        XCTAssertEqual(pictures[1].id, "2")
    }
    
    func testGetPicturesEmptyResponse() async throws {
        // Given
        let emptyJSON = "[]".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let testableNetworkManager = TestableNetworkManager(
            mockData: emptyJSON,
            mockResponse: mockResponse,
            mockError: nil
        )
        
        // When
        let pictures = try await testableNetworkManager.getPictures()
        
        // Then
        XCTAssertEqual(pictures.count, 0)
    }
    
    // MARK: - Error Cases
    
    func testGetPicturesNetworkError() async {
        // Given
        let networkError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet,
            userInfo: nil
        )
        
        let testableNetworkManager = TestableNetworkManager(
            mockData: nil,
            mockResponse: nil,
            mockError: networkError
        )
        
        // When & Then
        do {
            _ = try await testableNetworkManager.getPictures()
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, URLError.Code.notConnectedToInternet.rawValue)
            XCTAssertEqual(nsError.localizedDescription, "Please check your network connection.")
        }
    }
    
    func testGetPicturesNoData() async {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let testableNetworkManager = TestableNetworkManager(
            mockData: nil,
            mockResponse: mockResponse,
            mockError: nil
        )
        
        // When & Then
        do {
            _ = try await testableNetworkManager.getPictures()
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 200)
        }
    }
    
    func testGetPicturesInvalidJSON() async {
        // Given
        let invalidJSON = "invalid json".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let testableNetworkManager = TestableNetworkManager(
            mockData: invalidJSON,
            mockResponse: mockResponse,
            mockError: nil
        )
        
        // When & Then
        do {
            _ = try await testableNetworkManager.getPictures()
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 200)
        }
    }
    
    func testGetPicturesAuthenticationError() async {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 401,
            httpVersion: nil,
            headerFields: nil
        )
        
        let testableNetworkManager = TestableNetworkManager(
            mockData: Data(),
            mockResponse: mockResponse,
            mockError: nil
        )
        
        // When & Then
        do {
            _ = try await testableNetworkManager.getPictures()
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 401)
        }
    }
    
    func testGetPicturesServerError() async {
        // Given
        let mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        
        let testableNetworkManager = TestableNetworkManager(
            mockData: Data(),
            mockResponse: mockResponse,
            mockError: nil
        )
        
        // When & Then
        do {
            _ = try await testableNetworkManager.getPictures()
            XCTFail("Expected error to be thrown")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.code, 500)
        }
    }
    
}
