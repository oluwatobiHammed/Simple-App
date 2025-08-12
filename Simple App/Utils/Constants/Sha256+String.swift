//
//  Sha256+String.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

// MARK: - String Extension for URL Hashing
extension String {
    func sha256() -> String {
        return self.data(using: .utf8)?.base64EncodedString() ?? self
    }
}
