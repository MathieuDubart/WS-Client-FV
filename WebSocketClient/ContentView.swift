//
//  ContentView.swift
//  WebSocketClient
//
//  Created by digital on 22/10/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var wsClient = WebSocketClient.shared
    
    @State private var image: UIImage?
    @State private var isCameraPresented: Bool = false
    
    @StateObject var imageRecognitionManager = ImageRecognitionManager()
    @State var showDescription: Bool = false
    @State var textToShow: String?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else {
                Text("Aucune image prise")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            Text(imageRecognitionManager.imageDescription)
            
            /*if wsClient.receivedMessages.isEmpty {
                Text("No message received")
            } else {
                List{
                    ForEach(wsClient.receivedMessages) { message in
                        Text(message.content)
                    }
                }
            }*/
            
            Spacer()
                .frame(height: 40)
            
            Button(action: {
                isCameraPresented = true
            }) {
                Text("Prendre une photo")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
                .frame(height: 20)
            
            Button("Send image and prompt") {
                if let uiImage = self.image {
                    wsClient.sendImageAndPrompt(image: uiImage, prompt: "CoreML a reconnu ceci dans l'image: \(imageRecognitionManager.imageDescription). À ton tour de me décrire ce que tu y vois, en une seule phrase courte.", toRoute: "imagePromptingToText")
                }
            }
        }
        .padding()
        .onChange(of: self.image) {
            if let img = self.image {
                imageRecognitionManager.recognizeObjectsIn(image: img)
            }
        }
        .onChange(of: wsClient.receivedMessages) { oV, nV in
            if let msg = nV.last {
                print("Last message received: \(msg)")
                self.textToShow = msg.content
                SpeechSynthesizer.shared.speak(text: msg.content)
                self.showDescription.toggle()
            }
        }
        .onAppear {
            wsClient.connectTo(route:"imagePromptingToText")
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraView(image: $image)
        }
        .sheet(isPresented: $showDescription) {
            VStack {
                Text("Image Decsription")
                    .font(.largeTitle)
                Spacer()
                    .frame(height: 35)
                
                if let txt = self.textToShow {
                    Text(txt)
                }
                
                Spacer()
                    .frame(height: 35)
                
                Button("Dismiss", role: .destructive) {
                    self.showDescription.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        
    }
}

#Preview {
    ContentView()
}
