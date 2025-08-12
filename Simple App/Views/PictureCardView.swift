//
//  PictureCardView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
import SwiftUI

// MARK: - Picture Card View
struct PictureCardView<G: Gesture>: View {
    let picture: Pictures
    let onDelete: () -> Void
    @State private var imageLoaded = false
    @State private var showDeleteAlert = false
    @Environment(\.colorScheme) var colorScheme
    let dragGesture: G
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var textColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.gray : Color.secondary
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Image Section with fixed aspect ratio to prevent jumping
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(colorScheme == .dark ? 0.3 : 0.1),
                                Color.purple.opacity(colorScheme == .dark ? 0.3 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(16/9, contentMode: .fit) // Fixed aspect ratio
                
                CachedAsyncImage(url: picture.downloadUrl ?? "") { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill) // Match the container ratio
                        .onAppear {
                            // Only animate if not already loaded to prevent jumping
                            if !imageLoaded {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    imageLoaded = true
                                }
                            } else {
                                imageLoaded = true
                            }
                        }
                } placeholder: {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.blue)
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill the placeholder space
                }
                .clipped()
                
                // Delete button overlay
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showDeleteAlert = true }) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                                .background(
                                    Circle()
                                        .fill(cardBackgroundColor)
                                        .shadow(color: .black.opacity(0.2), radius: 3)
                                )
                        }
                        .padding()
                        .scaleEffect(imageLoaded ? 1.0 : 0.8)
                        .opacity(imageLoaded ? 1.0 : 0.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: imageLoaded)
                    }
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Author Info Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text(picture.author ?? "")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(textColor)
                        }
                        
                        HStack {
                            Image(systemName: "photo")
                                .foregroundColor(secondaryTextColor)
                            Text("\(picture.width) × \(picture.height)")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: imageLoaded ? "checkmark.circle.fill" : "arrow.down.circle")
                                    .foregroundColor(imageLoaded ? .green : .orange)
                                    .font(.caption)
                                
                                Text(imageLoaded ? "Cached" : "Loading")
                                    .font(.caption2)
                                    .foregroundColor(imageLoaded ? .green : .orange)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((imageLoaded ? Color.green : Color.orange).opacity(0.15))
                            .clipShape(Capsule())
                            
                            Text("ID: \(picture.id)")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(colorScheme == .dark ? 0.3 : 0.1))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    // Drag handle - more visible in dark mode
                    VStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(secondaryTextColor)
                                .frame(width: 18, height: 2)
                        }
                    }
                    .contentShape(Rectangle()) // Makes the whole area tappable
                    .gesture(dragGesture)      // Attach gesture here
                }
            }
            .padding()
            .background(cardBackgroundColor)
        }
        .background(cardBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.1),
            radius: 10,
            x: 0,
            y: 4
        )
        .alert("Delete Picture", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this picture by \(picture.author ?? "")? This will also remove it from cache.")
        }
    }
}

