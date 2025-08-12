//
//  MockNetworkManager.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

// MARK: - Unit Tests
import XCTest
@testable import Simple_App

// Mock NetworkManager for testing
class MockNetworkManager: NetworkManagerProtocol {
    var shouldThrowError = false
    var mockPictures: [Pictures] = []
    
    func getPictures() async throws -> [Pictures] {
        if shouldThrowError {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        }
        return mockPictures
    }
}
