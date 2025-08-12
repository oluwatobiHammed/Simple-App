//
//  MockRouter.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//
import XCTest
@testable import Simple_App
class MockRouter: NetworkRouter {
    typealias EndPoint = Endpoints
    
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func request(_ route: Endpoints) async -> (Data?, URLResponse?, Error?) {
        return (mockData, mockResponse, mockError)
    }
}
