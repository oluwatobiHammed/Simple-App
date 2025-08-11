//
//  ContentView.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
               let pictures = try await NetworkManager().getPictures()
                print(pictures)
            } catch {
                print(error)
            }
        }
    }
}

//#Preview {
//    ContentView()
//}
