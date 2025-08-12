//
//  Simple_AppApp.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import SwiftUI

@main
struct Simple_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: PicturesViewModel())
        }
    }
}
