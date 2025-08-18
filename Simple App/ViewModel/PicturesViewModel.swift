//
//  PicturesViewModel.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

// MARK: - ViewModel
import SwiftUI

@MainActor
class PicturesViewModel: ObservableObject {
    @Published var pictures: [Pictures] = []
    @Published var addPictures: [Pictures] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRefreshing = false
    @Published var counter = 0
    
    private let networkManager: NetworkManagerProtocol
    private let userDefaults = UserDefaults.standard
    private let picturesKey = "savedPictures"
    private let picturesCounterKey = "savedPicturesCounter"
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
        loadSavedPictures()
    }
    
    func fetchAndSavePicture() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedPictures = try await networkManager.getPictures()

            if fetchedPictures.isEmpty {
                pictures.removeAll()
            } else {
                var updatedPictures = pictures
                for newPicture in fetchedPictures {
                    if !updatedPictures.contains(where: { $0.id == newPicture.id }) {
                        updatedPictures.insert(newPicture, at: 0)
                    }
                }
                pictures = updatedPictures
            }

           
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading pictures: \(error)")
        }
        //savePictures()
        isLoading = false
    }
    
    func addNewImages() {
        
        let startingCounter = counter
        
        // Keep searching until we find a unique picture or reach the end
        while counter < pictures.count {
            let currentPicture = pictures[counter]
            
            // Check if picture already exists
            if addPictures.contains(where: { $0.id == currentPicture.id }) {
                counter += 1 // Skip this one
                continue
            }
            
            // Found a unique picture - add it
            let insertionIndex = min(startingCounter, addPictures.count)
            addPictures.insert(currentPicture, at: insertionIndex)
            
            counter += 1
            savePictures()
            
            return // Exit after adding one picture
        }
        
        print("No more unique pictures to add")
   
    }
    
    func deletePicture(at offsets: IndexSet) {
        counter -= 1
        print(counter)
        addPictures.remove(atOffsets: offsets)
        savePictures()
    }
    
    func deletePicture(withId id: String) {
        counter -= 1
        addPictures.removeAll { $0.id == id }
        savePictures()
    }
    
    func movePicture(from source: Int, to destination: Int) {

        guard source != destination,
              addPictures.indices.contains(source),
              (0...addPictures.count).contains(destination) else {
            return
        }
        
        let item = addPictures.remove(at: source)
        addPictures.insert(item, at: destination)
        savePictures()
    }
    
    private func savePictures() {
        if let encoded = try? JSONEncoder().encode(addPictures) {
            userDefaults.set(encoded, forKey: picturesKey)
        }
        
        userDefaults.set(counter, forKey: picturesCounterKey)
    }
    
    private func loadSavedPictures() {
        if let data = userDefaults.data(forKey: picturesKey),
           let decoded = try? JSONDecoder().decode([Pictures].self, from: data) {
            addPictures = decoded
        }
        
        counter = userDefaults.integer(forKey: picturesCounterKey)
    }
    
    func refreshPictures() async {
        isRefreshing = true
        await fetchAndSavePicture()
        isRefreshing = false
    }
}
