//
//  PicturesPerformanceTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//

import XCTest
@testable import Simple_App

@MainActor
final class PicturesPerformanceTests: XCTestCase {
    
    var viewModel: PicturesViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = PicturesViewModel(networkManager: mockNetworkManager)
        mockNetworkManager.mockPictures = []
        mockNetworkManager.shouldThrowError = false
        viewModel.pictures = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    func testFetchPerformance() async {
        // Prepare mock data
        let largePictureSet = (1...1000).map { i in
            Pictures(id: "\(i)", author: "Alejandro Escamilla \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        }
        mockNetworkManager.mockPictures = largePictureSet
        
        // Measure using Date()
        let start = Date()
        await viewModel.fetchAndSavePicture()
        let elapsed = Date().timeIntervalSince(start)
        print("Fetch and save took \(elapsed) seconds")
        
        XCTAssertLessThan(elapsed, 5.0) // Or whatever threshold you want
    }


    
    func testDeletionPerformance() {
        // Setup large dataset
        let largePictureSet = (1...1000).map { i in
            Pictures(id: "\(i)", author: "Alejandro Escamilla \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        }
        viewModel.pictures = largePictureSet
        
        measure {
            // Delete every 10th item
            for i in stride(from: 990, through: 0, by: -10) {
                viewModel.deletePicture(at: IndexSet([i]))
            }
        }
    }
    
    func testMovePerformance() {
        let pictureSet = (1...100).map { i in
            Pictures(id: "\(i)", author: "Alejandro Escamilla \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        }
        viewModel.pictures = pictureSet

        measure {
            for i in 0..<50 {
                let fromIndex = i % viewModel.pictures.count
                let toIndex = (viewModel.pictures.count - 1) - (i % viewModel.pictures.count)
                viewModel.movePicture(from: fromIndex, to: toIndex)
            }
        }

        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testMovePictureSmallSet() {
        viewModel.pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "...", downloadUrl: "...", width: 5000, height: 3333),
            Pictures(id: "3", author: "Alejandro Escamilla", url: "...", downloadUrl: "...", width: 5000, height: 3333),
            Pictures(id: "4", author: "Alejandro Escamilla", url: "...", downloadUrl: "...", width: 5000, height: 3333)
        ]

        // Move first item to position 2
        viewModel.movePicture(from: 0, to: 2)

        let expectedOrder = ["3", "4", "1"]
        let actualOrder = viewModel.pictures.map { $0.id }
        XCTAssertEqual(actualOrder, expectedOrder)
    }


    
    func testErrorRecoveryScenario() async {
        // Scenario: Network fails, then recovers
        
        // Step 1: Initial successful fetch
        mockNetworkManager.mockPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        await viewModel.fetchAndSavePicture()
        XCTAssertEqual(viewModel.pictures.count, 1)
        XCTAssertNil(viewModel.errorMessage)
        
        // Step 2: Network fails
        mockNetworkManager.shouldThrowError = true
        await viewModel.fetchAndSavePicture()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.pictures.count, 1) // Should retain existing pictures
        
        // Step 3: Network recovers
        mockNetworkManager.shouldThrowError = false
        mockNetworkManager.mockPictures = [
            Pictures(id: "2", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        
        await viewModel.fetchAndSavePicture()
        XCTAssertNil(viewModel.errorMessage) // Error should be cleared
        XCTAssertEqual(viewModel.pictures.count, 2)
        XCTAssertEqual(viewModel.pictures[0].id, "2") // New picture first
    }
    
    func testLargeDataSetHandling() async {
        // Prepare large dataset of 100 pictures
        let largePictureSet = (1...100).map { i in
            Pictures(id: "\(i)", author: "Author \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/\(i)/5000/3333", width: 5000, height: 3333)
        }
        
        mockNetworkManager.mockPictures = largePictureSet
        
        // Measure fetch performance
        let startTime = CFAbsoluteTimeGetCurrent()
        await viewModel.fetchAndSavePicture()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Verify the number of pictures loaded matches mock data
        XCTAssertEqual(viewModel.pictures.count, 100, "Should load all 100 pictures")
        
        // Verify no error occurred during fetch
        XCTAssertNil(viewModel.errorMessage)
        
        // Verify first picture is the last in the mock list (since new pictures inserted at front)
        XCTAssertEqual(viewModel.pictures.first?.id, "100", "Newest picture should be first in list")
        
        // Verify last picture is the first in the mock list
        XCTAssertEqual(viewModel.pictures.last?.id, "1", "Oldest picture should be last in list")
        
        // Optional: Assert performance threshold (e.g. under 2 seconds)
        XCTAssertLessThan(timeElapsed, 2.0, "Fetching and saving should complete under 2 seconds")
    }

}
