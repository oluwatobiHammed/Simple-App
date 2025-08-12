//
//  DragHandle.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

// MARK: - Drag Handle Component
struct DragHandle<GestureType: Gesture>: View {
    let dragGesture: GestureType
    @GestureState private var isDragging = false
    @Environment(\.colorScheme) var colorScheme
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? Color.gray : Color.secondary
    }
    
    var body: some View {
        VStack(spacing: 4) {
            VStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(isDragging ? Color.blue : secondaryTextColor)
                        .frame(width: 18, height: 3)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDragging ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
            )
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
            
            Text("Drag")
                .font(.caption2)
                .foregroundColor(isDragging ? .blue : secondaryTextColor)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
        )
        .simultaneousGesture(dragGesture)
    }
}
