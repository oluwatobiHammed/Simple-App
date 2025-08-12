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
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRefreshing = false
    
    private let networkManager: NetworkManagerProtocol
    private let userDefaults = UserDefaults.standard
    private let picturesKey = "savedPictures"
    
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

            savePictures()
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading pictures: \(error)")
        }

        isLoading = false
    }
    
    func deletePicture(at offsets: IndexSet) {
        pictures.remove(atOffsets: offsets)
        savePictures()
    }
    
    func deletePicture(withId id: String) {
        pictures.removeAll { $0.id == id }
        savePictures()
    }
    
    func movePicture(from source: Int, to destination: Int) {

        guard source != destination,
              pictures.indices.contains(source),
              (0...pictures.count).contains(destination) else {
            return
        }
        
        let item = pictures.remove(at: source)
        pictures.insert(item, at: destination)
        savePictures()
    }
    
    private func savePictures() {
        if let encoded = try? JSONEncoder().encode(pictures) {
            userDefaults.set(encoded, forKey: picturesKey)
        }
    }
    
    private func loadSavedPictures() {
        if let data = userDefaults.data(forKey: picturesKey),
           let decoded = try? JSONDecoder().decode([Pictures].self, from: data) {
            pictures = decoded
        }
    }
    
    func refreshPictures() async {
        isRefreshing = true
        await fetchAndSavePicture()
        isRefreshing = false
    }
}
