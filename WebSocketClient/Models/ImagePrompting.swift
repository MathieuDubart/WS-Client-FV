//
//  ImagePrompting.swift
//  WebSocketClient
//
//  Created by digital on 23/10/2024.
//

import Foundation

struct ImagePrompting: Codable {
    let prompt: String
    let imagesBase64Data: [String]
}
