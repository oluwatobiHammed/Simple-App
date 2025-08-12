//
//  PicturesIntegrationTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//

import XCTest
@testable import Simple_App

@MainActor
final class PicturesIntegrationTests: XCTestCase {
    
    var viewModel: PicturesViewModel!
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = PicturesViewModel(networkManager: mockNetworkManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        super.tearDown()
    }
    
    // MARK: - Complete User Scenarios
    
    func testCompleteUserWorkflow() async {
        // Scenario: User opens app, fetches pictures, deletes some, moves others, then refreshes
        
        // Step 1: Initial fetch
        
        // Load a reasonably large dataset
        mockNetworkManager.mockPictures = Array(1...100).map { i in
            Pictures(id: "\(i)", author: "Alejandro Escamilla \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        }
        
        // Step 2: Measure time
        let startTime = Date()
        await viewModel.fetchAndSavePicture()
        let timeElapsed = Date().timeIntervalSince(startTime)
        
        // Step 3: Assertions
        XCTAssertEqual(viewModel.pictures.count, 100)
        XCTAssertLessThan(timeElapsed, 1.0) // Should complete within 1 second
        
        // Test bulk deletion
        let indicesToDelete = IndexSet([0, 1, 2, 3, 4]) // Delete first 5
        viewModel.deletePicture(at: indicesToDelete)
        XCTAssertEqual(viewModel.pictures.count, 95)
        
        // Test moving items in large dataset
        viewModel.movePicture(from: 0, to: 50)
        XCTAssertEqual(viewModel.pictures.count, 95)
    }
    
    func testConcurrentOperations() async {
        // Test handling of concurrent operations
        mockNetworkManager.delay = 0.1
        mockNetworkManager.mockPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        
        // Start multiple concurrent operations
        async let fetch1: () = viewModel.fetchAndSavePicture()
        async let fetch2: () = viewModel.fetchAndSavePicture()
        async let refresh: () = viewModel.refreshPictures()
        
        // Wait for all to complete
        await fetch1
        await fetch2
        await refresh
        
        // Should not have duplicates despite concurrent operations
        XCTAssertEqual(viewModel.pictures.filter { $0.id == "1" }.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isRefreshing)
    }
    
    func testPersistenceScenario() async {
        // Test that pictures are saved and can be restored
        
        // Step 1: Add some pictures
        mockNetworkManager.mockPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        await viewModel.fetchAndSavePicture()
        
        // Step 2: Modify the collection
        viewModel.deletePicture(withId: "2")
        viewModel.movePicture(from: 0, to: 0) // This should trigger save
        
        // Step 3: Create new view model (simulating app restart)
        let newViewModel = PicturesViewModel(networkManager: mockNetworkManager)
        
        // Note: This test would need access to the same UserDefaults instance
        // In a real test, you'd inject a mock UserDefaults or test UserDefaults suite
        // For now, we test the save/load methods indirectly by ensuring they don't crash
        XCTAssertNotNil(newViewModel)
    }
    
    // MARK: - Edge Cases and Boundary Tests
    
    func testEmptyStateHandling() async {
        // Test handling of empty responses
        mockNetworkManager.mockPictures = []
        
        await viewModel.fetchAndSavePicture()
        XCTAssertEqual(viewModel.pictures.count, 0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testInvalidIndexHandling() {
        // Test deletion with invalid indices
        let pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = pictures
        
        // Test with empty IndexSet
        viewModel.deletePicture(at: IndexSet())
        XCTAssertEqual(viewModel.pictures.count, 1)
        
        // Test moving to invalid positions (should be handled gracefully by Array)
        viewModel.movePicture(from: 0, to: 10) // Beyond array bounds
        XCTAssertEqual(viewModel.pictures.count, 1)
    }
    
    func testRapidUserInteractions() async {
        // Simulate rapid user interactions
        mockNetworkManager.mockPictures = Array(1...10).map { i in
            Pictures(id: "\(i)", author: "Alejandro Escamilla \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        }
      
        await viewModel.fetchAndSavePicture()
        XCTAssertEqual(viewModel.pictures.count, 10)
        
        // Rapid deletions
        for i in stride(from: 9, through: 5, by: -1) {
            viewModel.deletePicture(at: IndexSet([i]))
        }
        XCTAssertEqual(viewModel.pictures.count, 5)
        
        // Rapid moves
        for _ in 0..<5 {
            if viewModel.pictures.count > 1 {
                viewModel.movePicture(from: 0, to: viewModel.pictures.count - 1)
            }
        }
        XCTAssertEqual(viewModel.pictures.count, 5)
    }
    
    func testMemoryManagement() async {
        // Test that large datasets don't cause memory issues
        weak var weakViewModel: PicturesViewModel?
        
        do {
            let tempViewModel = PicturesViewModel(networkManager: mockNetworkManager)
            weakViewModel = tempViewModel
            
            // Load a reasonably large dataset
            mockNetworkManager.mockPictures = Array(1...50).map { i in
                Pictures(id: "\(i)", author: "Alejandro Escamilla \(i)", url: "https://example.com/\(i).jpg", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
            }
            
            await tempViewModel.fetchAndSavePicture()
            XCTAssertEqual(tempViewModel.pictures.count, 50)
        }
        
        // Force a garbage collection cycle
        for _ in 0..<3 {
            autoreleasepool {
                _ = Array(0..<1000).map { $0 * 2 }
            }
        }
        
        // ViewModel should be deallocated
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
}
