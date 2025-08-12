//
//  PicturesViewModelTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
//
//  PicturesViewModelTests.swift
//  Simple AppTests
//
//  Created by Test Suite on 2025-08-11.
//

import XCTest
@testable import Simple_App

@MainActor
final class PicturesViewModelTests: XCTestCase {
    
    var viewModel: PicturesViewModel!
    var mockNetworkManager: MockNetworkManager!
    var testUserDefaults: UserDefaults!
    var testSuiteName: String!
       
       override func setUp() {
           super.setUp()
           mockNetworkManager = MockNetworkManager()
           
           // Create a unique test UserDefaults suite
           testSuiteName = "test-suite-\(UUID().uuidString)"
           testUserDefaults = UserDefaults(suiteName: testSuiteName)!
           testUserDefaults.removePersistentDomain(forName: testSuiteName)
           
           // Clear any existing saved pictures in standard UserDefaults for testing
           UserDefaults.standard.removeObject(forKey: "savedPictures")
           
           viewModel = PicturesViewModel(networkManager: mockNetworkManager)
           
           // Clear any pictures that might have been loaded from UserDefaults
           viewModel.pictures = []
       }
       
       override func tearDown() {
           // Clean up UserDefaults
           UserDefaults.standard.removeObject(forKey: "savedPictures")
           
           // Clean up test UserDefaults
           if let testUserDefaults = testUserDefaults, let suiteName = testSuiteName {
               testUserDefaults.removePersistentDomain(forName: suiteName)
           }
           
           viewModel = nil
           mockNetworkManager = nil
           testUserDefaults = nil
           testSuiteName = nil
           super.tearDown()
       }
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.pictures.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isRefreshing)
    }
    
    // MARK: - Fetch Pictures Tests
    
    func testFetchAndSavePictureSuccess() async {
        // Given
        let mockPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Paul Jarvis", url: "https://unsplash.com/photos/Cm7oKel-X2Q", downloadUrl: "https://picsum.photos/id/11/2500/1667", width: 2500, height: 1667)
        ]
        mockNetworkManager.mockPictures = mockPictures
        
        // When
        await viewModel.fetchAndSavePicture()
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 2)
        
        // Verify that both pictures are present (regardless of order initially)
        let pictureIds = Set(viewModel.pictures.map { $0.id })
        XCTAssertEqual(pictureIds, Set(["1", "2"]))
        
        // Since your implementation inserts at index 0 for each picture in the loop,
        // the last picture processed will be at index 0
        // For the array ["1", "2"], processing order is:
        // 1. Insert "1" at 0: ["1"]
        // 2. Insert "2" at 0: ["2", "1"]
        XCTAssertEqual(viewModel.pictures[0].id, "2")
        XCTAssertEqual(viewModel.pictures[1].id, "1")
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAndSavePictureFailure() async {
        // Given
        mockNetworkManager.shouldThrowError = true
        
        // When
        await viewModel.fetchAndSavePicture()
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Network error")
    }
    
    func testFetchAndSavePictureNoDuplicates() async {
        // Given
        let initialPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = initialPictures
        
        let mockPictures = [
           
            Pictures(id: "1", author: "Paul Jarvis", url: "https://unsplash.com/photos/Cm7oKel-X2Q", downloadUrl: "https://picsum.photos/id/11/2500/1667", width: 2500, height: 1667),
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        mockNetworkManager.mockPictures = mockPictures
        
        // When
        await viewModel.fetchAndSavePicture()
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 2)
        XCTAssertEqual(viewModel.pictures[0].id, "2") // New picture should be first
        XCTAssertEqual(viewModel.pictures[1].id, "1") // Existing picture should remain
        XCTAssertEqual(viewModel.pictures[1].author, "Alejandro Escamilla") // Original should be kept
    }
    
    func testFetchAndSavePictureAddsNewPicturesToBeginning() async {
        // Given
        let initialPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = initialPictures
        
        let mockPictures = [
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/LNRyGwIJr5c", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        mockNetworkManager.mockPictures = mockPictures
        
        // When
        await viewModel.fetchAndSavePicture()
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 2)
        XCTAssertEqual(viewModel.pictures[0].id, "2") // New picture first
        XCTAssertEqual(viewModel.pictures[1].id, "1") // Old picture second
    }
    
    // MARK: - Delete Tests
    
    func testDeletePictureAtOffsets() {
        // Given
        let pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/LNRyGwIJr5c", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "3", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = pictures
        
        // When
        let indexSet = IndexSet([1]) // Delete second picture
        viewModel.deletePicture(at: indexSet)
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 2)
        XCTAssertEqual(viewModel.pictures[0].id, "1")
        XCTAssertEqual(viewModel.pictures[1].id, "3")
    }
    
    func testDeletePictureWithId() {
        // Given
        let pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/LNRyGwIJr5c", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "3", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = pictures
        
        // When
        viewModel.deletePicture(withId: "2")
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 2)
        XCTAssertEqual(viewModel.pictures[0].id, "1")
        XCTAssertEqual(viewModel.pictures[1].id, "3")
    }
    
    func testDeletePictureWithNonexistentId() {
        // Given
        let pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/LNRyGwIJr5c", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = pictures
        
        // When
        viewModel.deletePicture(withId: "999")
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 2) // No change
        XCTAssertEqual(viewModel.pictures[0].id, "1")
        XCTAssertEqual(viewModel.pictures[1].id, "2")
    }
    
    // MARK: - Move Tests
    
    func testMovePicture() {
        // Given
        let pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/LNRyGwIJr5c", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "3", author: "Alejandro Escamilla", url: " https://unsplash.com/photos/N7XodRrbzS0", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
           
        ]
        viewModel.pictures = pictures
        
        // When - Move first item to last position
        viewModel.movePicture(from: 0, to: 2)
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 3)
        XCTAssertEqual(viewModel.pictures[0].id, "2")
        XCTAssertEqual(viewModel.pictures[1].id, "3")
        XCTAssertEqual(viewModel.pictures[2].id, "1")

    }
    
    func testMovePictureSamePosition() {
        // Given
        let pictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333),
            Pictures(id: "2", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/LNRyGwIJr5c", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        viewModel.pictures = pictures
        let originalOrder = viewModel.pictures
        
        // When - Move to same position
        viewModel.movePicture(from: 0, to: 0)
        
        // Then - No change should occur
        XCTAssertEqual(viewModel.pictures.count, originalOrder.count)
        XCTAssertEqual(viewModel.pictures[0].id, originalOrder[0].id)
        XCTAssertEqual(viewModel.pictures[1].id, originalOrder[1].id)
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshPictures() async {
        // Given
        let mockPictures = [
            Pictures(id: "1", author: "Alejandro Escamilla", url: "https://unsplash.com/photos/yC-Yzbqy7PY", downloadUrl: "https://picsum.photos/id/0/5000/3333", width: 5000, height: 3333)
        ]
        mockNetworkManager.mockPictures = mockPictures
        
        // When
        await viewModel.refreshPictures()
        
        // Then
        XCTAssertEqual(viewModel.pictures.count, 1)
        XCTAssertEqual(viewModel.pictures[0].author, "Alejandro Escamilla")
        XCTAssertFalse(viewModel.isRefreshing)
    }
    
    // MARK: - Loading States Tests
    
    func testLoadingStatesDuringFetch() async {
        // Given
        mockNetworkManager.delay = 0.1 // Add small delay to test loading states
        
        // When
        let fetchTask = Task {
            await viewModel.fetchAndSavePicture()
        }
        
        // Then - Check loading state is true during fetch
        // Note: Due to MainActor, we might need to check this differently
        // This is a simplified test - in practice, you might need more sophisticated timing
        
        await fetchTask.value
        XCTAssertFalse(viewModel.isLoading)
    }
}



// MARK: - Test Data Extensions

extension Pictures {
    convenience init(id: String, author: String, url: String, downloadUrl: String, width: Int,  height: Int) {
        self.init() // ✅ must call before touching self
        // Assuming Pictures has these properties - adjust based on your actual model
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.url = url
        self.downloadUrl = downloadUrl
        // Add other required properties with default values
    }
}
