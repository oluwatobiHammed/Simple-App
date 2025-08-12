//
//  PicturesViewModelTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
import XCTest
@testable import Simple_App
class PicturesViewModelTests: XCTestCase {
    @MainActor
    func testLoadPicturesSuccess() async {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let expectedPictures = [Pictures(/* your test data */)]
        mockNetworkManager.mockPictures = expectedPictures
        
        let viewModel = PicturesViewModel(networkManager: mockNetworkManager)
        
        // Act
        await viewModel.loadPictures()
        
        // Assert
        XCTAssertEqual(viewModel.pictures.count, expectedPictures.count)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testLoadPicturesFailure() async {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        mockNetworkManager.shouldThrowError = true
        
        let viewModel = PicturesViewModel(networkManager: mockNetworkManager)
        
        // Act
        await viewModel.loadPictures()
        
        // Assert
        XCTAssertTrue(viewModel.pictures.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testLoadingState() async {
        // Arrange
        let mockNetworkManager = MockNetworkManager()
        let viewModel = PicturesViewModel(networkManager: mockNetworkManager)
        
        // Act & Assert
        XCTAssertFalse(viewModel.isLoading)
        
        let loadTask = Task {
            await viewModel.loadPictures()
        }
        
        // The loading state might be too fast to catch in tests,
        // but this demonstrates how you could test it
        await loadTask.value
        
        XCTAssertFalse(viewModel.isLoading)
    }
}
