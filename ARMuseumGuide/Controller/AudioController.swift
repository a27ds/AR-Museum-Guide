//
//  AudioController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-12-13.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import AVFoundation

class AudioController {
    
    var haveAudioBeenStarted = false
    var isAudioPaused = false
    var utterance = AVSpeechUtterance()
    var synth = AVSpeechSynthesizer()
    
    init() {
        haveAudioBeenStarted = false
        isAudioPaused = false
    }
    
    
    func startTextToSpeech(_ text: String) {
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
        isAudioPaused = false
    }
    
    func pauseOrPlayTextToSpeech () {
        if (isAudioPaused) {
            synth.continueSpeaking()
            isAudioPaused = false
        } else {
            synth.pauseSpeaking(at: .word)
            isAudioPaused = true
            
        }
    }
    
    
    
    
}
