//
//  MockNetworkManager.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

// MARK: - Unit Tests
import XCTest
@testable import Simple_App

// MARK: - Mock Network Manager

class MockNetworkManager: NetworkManagerProtocol {
    var mockPictures: [Pictures] = []
    var shouldThrowError = false
    var delay: TimeInterval = 0
    
    func getPictures() async throws -> [Pictures] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        }
        
        return mockPictures
    }
}
