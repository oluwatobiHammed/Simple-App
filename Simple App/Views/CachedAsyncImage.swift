//
//  CachedAsyncImage.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI
// MARK: - Cached Async Image View
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @StateObject private var cacheManager = ImageCacheManager.shared
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(
        url: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
        .id(url) // This helps with smooth scrolling
    }
    
    @MainActor
    private func loadImage() async {
        // Check cache first
        if let cachedImage = cacheManager.getImage(from: url) {
            self.image = cachedImage
            return
        }
        
        // Load from network
        guard let imageUrl = URL(string: url) else { return }
        
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageUrl)
            isLoading = false
            
            if let downloadedImage = UIImage(data: data) {
                // Cache the image
                cacheManager.cacheImage(downloadedImage, for: url)
                
                // Update UI
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.image = downloadedImage
                }
            }
        } catch {
            isLoading = false
            print("Failed to load image: \(error.localizedDescription)")
        }
    }
}
