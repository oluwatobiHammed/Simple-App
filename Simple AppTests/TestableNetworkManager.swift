//
//  TestableNetworkManager.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//
import XCTest
@testable import Simple_App
// MARK: - Test Helpers

class TestableNetworkManager: NetworkManagerProtocol {
    private let mockData: Data?
    private let mockResponse: URLResponse?
    private let mockError: Error?
    
    init(mockData: Data?, mockResponse: URLResponse?, mockError: Error?) {
        self.mockData = mockData
        self.mockResponse = mockResponse
        self.mockError = mockError
    }
    
    func getPictures() async throws -> [Pictures] {
        // Simulate the network manager behavior with mock data
        if mockError != nil {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Please check your network connection."]
            )
        }
        
        if let response = mockResponse as? HTTPURLResponse {
            let result = handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = mockData else {
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "No data"]
                    )
                }
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(
                        with: responseData,
                        options: .mutableContainers
                    )
                    print(jsonData) // Debug output
                    
                    guard let pics = try? [Pictures].decode(data: responseData) else {
                        throw NSError(
                            domain: "",
                            code: response.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "Unable to decode"]
                        )
                    }
                    
                    return pics
                } catch {
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Unable to decode"]
                    )
                }
            case .failure(let networkFailureError):
                throw networkFailureError
            }
        } else {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Please check your network connection."]
            )
        }
    }
}
