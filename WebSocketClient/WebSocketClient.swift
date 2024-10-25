//
//  WebsocketClient.swift
//  WebSocketClient
//
//  Created by digital on 22/10/2024.
//

import SwiftUI
import NWWebSocket
import Network

class WebSocketClient: ObservableObject {
    struct Message: Identifiable, Equatable {
        let id = UUID().uuidString
        let content:String
    }
    
    static let shared:WebSocketClient = WebSocketClient()
    
    var routes = [String:NWWebSocket]()
    var ipAdress: String = "192.168.4.51:8080"
    @Published var receivedMessages: [Message] = []
    
    func connectTo(route:String) -> Void {
        let socketURL = URL(string: "ws://\(ipAdress)/\(route)")
        if let url = socketURL {
            let socket = NWWebSocket(url: url, connectAutomatically: true)
            
            socket.delegate = self
            socket.connect()
            routes[route] = socket
        }
    }
    
    /*func sendMessage(_ string: String) -> Void {
        guard let socket = socket else { print("No socket available"); return }
        socket.send(string: string)
    }*/
    
    func sendImageAndPrompt(image: UIImage, prompt: String, toRoute route: String) -> Void {
        if let imageData = image.jpegData(compressionQuality: 0.6) {
            let base64String = imageData.base64EncodedString()
            
            let jsonModel = ImagePrompting(prompt: prompt, imagesBase64Data: [base64String])
            
            if let json = try? JSONEncoder().encode(jsonModel), let jsonStringToSend = String(data: json, encoding: .utf8) {
                self.routes[route]?.send(string: jsonStringToSend)
                print("Json sent")
            } else {
                print("Error sending prompt and image")
            }
        }
    }
    
    func disconnect(route: String) {
        routes[route]?.disconnect()
    }
}

extension WebSocketClient: WebSocketConnectionDelegate {
    
    func webSocketDidConnect(connection: WebSocketConnection) {
        // Respond to a WebSocket connection event
        print("WebSocket connected")
    }

    func webSocketDidDisconnect(connection: WebSocketConnection,
                                closeCode: NWProtocolWebSocket.CloseCode, reason: Data?) {
        // Respond to a WebSocket disconnection event
        print("WebSocket disconnected")
    }

    func webSocketViabilityDidChange(connection: WebSocketConnection, isViable: Bool) {
        // Respond to a WebSocket connection viability change event
        print("WebSocket viability: \(isViable)")
    }

    func webSocketDidAttemptBetterPathMigration(result: Result<WebSocketConnection, NWError>) {
        // Respond to when a WebSocket connection migrates to a better network path
        // (e.g. A device moves from a cellular connection to a Wi-Fi connection)
    }

    func webSocketDidReceiveError(connection: WebSocketConnection, error: NWError) {
        // Respond to a WebSocket error event
        print("WebSocket error: \(error)")
    }

    func webSocketDidReceivePong(connection: WebSocketConnection) {
        // Respond to a WebSocket connection receiving a Pong from the peer
        print("WebSocket received Pong")
    }

    func webSocketDidReceiveMessage(connection: WebSocketConnection, string: String) {
        // Respond to a WebSocket connection receiving a `String` message
        print("WebSocket received message: \(string)")
        self.receivedMessages.append(Message(content: string))
    }

    func webSocketDidReceiveMessage(connection: WebSocketConnection, data: Data) {
        // Respond to a WebSocket connection receiving a binary `Data` message
        print("WebSocket received Data message \(data)")
    }
}
