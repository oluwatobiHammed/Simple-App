//
//  ContentViewTests.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-12.
//
import XCTest
import SwiftUI
import ViewInspector
@testable import Simple_App

@MainActor
final class ContentViewTests: XCTestCase {

    class MockPicturesViewModel: PicturesViewModel {
        var fetchCalled = false
        var refreshCalled = false
        var deleteCalledWithId: String?
        var moveCalledFrom: Int?
        var moveCalledTo: Int?
        
       // override var pictures: [Pictures] {
           // didSet { /* notify changes if needed */ }
      //  }
        
        override func fetchAndSavePicture() async {
         
                fetchCalled = true
                // Simulate loading state
                isLoading = true
                try? await Task.sleep(nanoseconds: 100_000_000)
                isLoading = false
         
        }
        
        override func refreshPictures() async {
            refreshCalled = true
        }
        
        override func deletePicture(withId id: String) {
            deleteCalledWithId = id
        }
        
        override func movePicture(from fromIndex: Int, to toIndex: Int) {
            moveCalledFrom = fromIndex
            moveCalledTo = toIndex
        }
    }
    
    func testFetchButtonDisabledWhenLoading() throws {
        let vm = MockPicturesViewModel()
        vm.isLoading = true
        let sut = ContentView(viewModel: vm)
         sut.inspect { view in
             let buttons =  view.findAll(ViewType.Button.self)

             let fetchButton = buttons.first(where: { button in
                 (try? button.find(ViewType.Text.self).string()) == "Fetch New Picture" ||
                 (try? button.find(ViewType.Text.self).string()) == "Fetching..."
             })
             XCTAssertNotNil(fetchButton)
             XCTAssertTrue(fetchButton!.isDisabled())
        }
    }



    
    func testErrorMessageVisible() throws {
        let vm = MockPicturesViewModel()
        vm.errorMessage = "Test Error"
        let sut = ContentView(viewModel: vm)
        let _: () = sut.inspect { view in
            XCTAssertNoThrow(try view.find(text: "Test Error"))
        }
        
    }
    
    func testEmptyStateVisibleWhenNoPictures() throws {
        let vm = MockPicturesViewModel()
        vm.pictures = []
        let sut = ContentView(viewModel: vm)
        let _: () = sut.inspect { view in
            XCTAssertNoThrow(try view.find(EmptyStateView.self))
        }
       
    }
    
    func testPicturesListCount() throws {
        let vm = MockPicturesViewModel()
        vm.pictures = [
            Pictures(id: "1", url: "url1"),
            Pictures(id: "2", url: "url2"),
            Pictures(id: "3", url: "url3")
        ]
        let sut = ContentView(viewModel: vm)
        sut.inspect { view in
            let cards = view.findAll(DraggablePictureCard.self)
            XCTAssertEqual(cards.count, 3)
        }
    }

    
    func testDeleteCallsViewModel() throws {
        let vm = MockPicturesViewModel()
        vm.pictures = [Pictures(id: "123", url: "url")]
        let sut = ContentView(viewModel: vm)
        let _: () = sut.inspect { view in
            let card = try view.find(DraggablePictureCard.self)
            try card.callOnDelete()
            XCTAssertEqual(vm.deleteCalledWithId, "123")
        }
        
    }
    
    func testMoveCallsViewModel() throws {
        let vm = MockPicturesViewModel()
        vm.pictures = [
            Pictures(id: "1", url: "url"),
            Pictures(id: "2", url: "url")
        ]
        let sut = ContentView(viewModel: vm)
        sut.inspect { view in
            let cards = view.findAll(DraggablePictureCard.self)
            let card = cards.first!
            try card.callOnMove(0, 1)  // simulate move from index 0 to 1
            XCTAssertEqual(vm.moveCalledFrom, 0)
            XCTAssertEqual(vm.moveCalledTo, 1)
        }
    }



}

extension Pictures {
    convenience init(id: String, url: String?) {
        self.init()
        self.id = id
        self.author = nil
        self.width = 0
        self.height = 0
        self.url = url
        self.downloadUrl = nil
    }
}


extension InspectableView where View == ViewType.View<DraggablePictureCard> {
    func callOnDelete() throws {
        let onDelete = try self.actualView().onDelete
        onDelete()
    }
    
    func callOnMove(_ from: Int, _ to: Int) throws {
        let onMove = try self.actualView().onMove
        onMove(from, to)
    }
}


//extension InspectableView where View == ViewType.View<ContentView> {
//    func callRefresh() async throws {
//        try await self.actualView().viewModel.refreshPictures()
//    }
//}





