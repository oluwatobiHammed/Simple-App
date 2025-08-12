//
//  DragDropState.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI
// MARK: - Drag and Drop State Manager
@MainActor
class DragDropState: ObservableObject {
    @Published var draggedItem: String?
    @Published var targetIndex: Int?
    @Published var isDragging = false
    
    func startDrag(itemId: String) {
        draggedItem = itemId
        isDragging = true
    }
    
    func endDrag() {
        draggedItem = nil
        targetIndex = nil
        isDragging = false
    }
    
    func updateTarget(index: Int) {
        targetIndex = index
    }
}

// MARK: - Draggable Picture Card
struct DraggablePictureCard: View {
    let picture: Pictures
    let index: Int
    let totalItemCount: Int
    let onDelete: () -> Void
    let onMove: (Int, Int) -> Void
    @StateObject private var dragState = DragDropState()
    @GestureState private var dragOffset = CGSize.zero
    @State private var isDraggedItem = false
    @State private var draggedItemId: String? = nil

    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onChanged { _ in
                if !isDraggedItem {
                    isDraggedItem = true
                    dragState.startDrag(itemId: picture.id)
                    draggedItemId = picture.id
                }
               
            }
            .onEnded { value in
                isDraggedItem = false
                draggedItemId = nil
                 let cardHeight: CGFloat = 280
                 let dragDistance = value.translation.height
                 let targetOffset = Int(round(dragDistance / cardHeight))
                 
                 // Calculate potential new index
                 var newIndex = index + targetOffset
                 
                 // Clamp between 0 and last index
                 let lastIndex = totalItemCount - 1
                 newIndex = max(0, min(lastIndex, newIndex))
                 
                 if newIndex != index {
                     onMove(index, newIndex)
                 }
                
                 dragState.endDrag()
            }
    }
    
    var body: some View {
        PictureCardView(picture: picture, onDelete: onDelete,
                        dragGesture: dragGesture)
            .scaleEffect(isDraggedItem ? 1.05 : 1.0)
            .shadow(
                color: isDraggedItem ? .blue.opacity(0.3) : .clear, 
                radius: isDraggedItem ? 15 : 0,
                x: 0,
                y: isDraggedItem ? 8 : 0
            )
            .offset(dragOffset)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDraggedItem)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
            .zIndex(isDraggedItem ? 1000 : Double(index))
            .onReceive(dragState.$draggedItem) { draggedId in
                isDraggedItem = (draggedId == picture.id)
            }
    }
}
