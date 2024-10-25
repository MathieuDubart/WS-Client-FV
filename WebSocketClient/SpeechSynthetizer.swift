//
//  SpeechSynthetizer.swift
//  WebSocketClient
//
//  Created by Al on 23/10/2024.
//

import Foundation
import AVFoundation

class SpeechSynthesizer {
    static let shared =  SpeechSynthesizer()
    private let synthesizer = AVSpeechSynthesizer()

    // Fonction pour faire parler l'iPhone
    func speak(text: String, language: String = "fr-FR") {
        guard !text.isEmpty else { return }  // S'assure que le texte n'est pas vide

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        synthesizer.speak(utterance)
    }
}
