//
//  ContentView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

// MARK: - Main ContentView

struct ContentView: View {
    @StateObject private var viewModel: PicturesViewModel
    @State private var showingEmptyState = false
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var dragState = DragDropState() // Shared drag state
    
    init(viewModel: PicturesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var backgroundGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color.black,
                    Color(.systemGray6),
                    Color(.systemGray5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.pink.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var titleGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [.cyan, .blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [.blue, .purple, .pink],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var buttonGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [Color.cyan, Color.blue],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header Section
                        VStack(spacing: 16) {
                            Text("Picture Gallery")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(titleGradient)
                            
                            Text("Discover and collect amazing pictures")
                                .font(.subheadline)
                                .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                            
                            // Fetch Button
                            Button(action: {
                                Task {
                                    await viewModel.fetchAndSavePicture()
                                }
                            }) {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "plus.circle.fill")
                                    }
                                    Text(viewModel.isLoading ? "Fetching..." : "Fetch New Picture")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(buttonGradient)
                                .clipShape(Capsule())
                                .shadow(color: colorScheme == .dark ? .cyan.opacity(0.3) : .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(viewModel.isLoading)
                            .scaleEffect(viewModel.isLoading ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: viewModel.isLoading)
                            
                            // Gallery Stats
                            if !viewModel.pictures.isEmpty {
                                HStack(spacing: 16) {
                                    HStack {
                                        Image(systemName: "photo.stack")
                                            .foregroundColor(.blue)
                                        Text("\(viewModel.pictures.count) picture\(viewModel.pictures.count == 1 ? "" : "s")")
                                            .font(.caption)
                                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                                    }
                                    
                                    // Cache info
                                    HStack {
                                        Image(systemName: "externaldrive.fill")
                                            .foregroundColor(.green)
                                        Text("Cache: \(ImageCacheManager.shared.getCacheSize())")
                                            .font(.caption)
                                            .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    (colorScheme == .dark ? Color(.systemGray5) : Color.white)
                                        .opacity(0.7)
                                )
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .padding()
                            .background(Color.orange.opacity(colorScheme == .dark ? 0.2 : 0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                        
                        // Pictures List
                        if viewModel.pictures.isEmpty {
                            EmptyStateView()
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(viewModel.pictures.enumerated()), id: \.element.id) { index, picture in
                                    DraggablePictureCard(
                                        picture: picture,
                                        index: index,
                                        totalItemCount: viewModel.pictures.count,
                                        onDelete: {
                                            viewModel.deletePicture(withId: picture.id)
                                        },
                                        onMove: { fromIndex, toIndex in
                                            viewModel.movePicture(from: fromIndex, to: toIndex)
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    await viewModel.refreshPictures()
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(nil) // Respects system setting
    }
}
//#Preview {
//    ContentView()
//}
extension Text {
    func multicolorGlow() -> some View {
        self
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple, .pink],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}


// MARK: - Drag and Drop Helper Extension
extension LazyVStack {
    func enableDragAndDrop() -> some View {
        self.environment(\.editMode, .constant(.active))
    }
}
