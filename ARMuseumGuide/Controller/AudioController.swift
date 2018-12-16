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
    var haveTextToSpeechBeenStarted = false
    var isTextToSpeechPaused = false
    var utterance = AVSpeechUtterance()
    var synth = AVSpeechSynthesizer()
    var player: AVPlayer!
    
    init() {
        haveAudioBeenStarted = false
        isAudioPaused = false
        haveTextToSpeechBeenStarted = false
        isTextToSpeechPaused = false
    }
    
    func startTextToSpeech(_ text: String) {
        if (haveAudioBeenStarted) {
            stopAudio()
        }
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
        isTextToSpeechPaused = false
        haveTextToSpeechBeenStarted = true
    }
    
    func stopTextToSpeech() {
        synth.stopSpeaking(at: .immediate)
        haveTextToSpeechBeenStarted = false
    }
    
    func pauseOrPlayTextToSpeech() {
        if (isTextToSpeechPaused) {
            synth.continueSpeaking()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
            isTextToSpeechPaused = false
        } else {
            synth.pauseSpeaking(at: .word)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
            isTextToSpeechPaused = true
        }
    }
    
    func pauseOrPlayAudio() {
        if (isAudioPaused) {
            print("isPlaying")
            player.play()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
            isAudioPaused = false
        } else {
            print("isPaused")
            player.pause()
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
            isAudioPaused = true
        }
    }
    
    func stopAudio() {
        player.pause()
        player = nil
        haveAudioBeenStarted = false
    }
    
    func streamAudio(Url: String) {
        if (haveTextToSpeechBeenStarted) {
            stopTextToSpeech()
        }
        let url  = URL.init(string: Url)
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        player = AVPlayer(playerItem: playerItem)
        player.play()
        isAudioPaused = false
        haveAudioBeenStarted = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
    }
}




