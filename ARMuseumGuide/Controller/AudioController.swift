//
//  AudioController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-12-13.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire

var globalAudioController: AudioController?

class AudioController {
    
    var haveAudioBeenStarted = false
    var isAudioPaused = false
    var haveTextToSpeechBeenStarted = false
    var isTextToSpeechPaused = false
    var utterance = AVSpeechUtterance()
    var synth = AVSpeechSynthesizer()
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var timer: Timer?
    var audioDownloadUrl: URL?
    var observer: NSKeyValueObservation?
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        stopAudio()
    }
    
    init() {
        globalAudioController = self
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
        timer?.invalidate()
        player.pause()
        player = nil
        haveAudioBeenStarted = false
        DispatchQueue.main.async {
            //need to do the change in an dispatchqueue, because the function is called from another thread then the main thread
            globalAudioViewController?.audioSlider.value = 0.0
        }
        
    }
    
    func streamAudio(Url: String) {
        if (haveTextToSpeechBeenStarted) {
            stopTextToSpeech()
        }
        
        downloadAudio(url: Url) {
            if let url = self.audioDownloadUrl {
                self.playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem: self.playerItem)
            }
            globalAudioViewController?.audioSlider.value = 0.0
            self.prepareToPlay()
            self.player.play()
            self.timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            self.isAudioPaused = false
            self.haveAudioBeenStarted = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        }
    }
    
    func prepareToPlay() {
        // Create asset to be played
        let asset = AVAsset(url: audioDownloadUrl!)
        
        let assetKeys = [
            "playable",
            "notPlayable"
        ]
        // Create a new AVPlayerItem with the asset and an
        // array of asset keys to be automatically loaded
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        
        // Register as an observer of the player item's status property
        self.observer = playerItem.observe(\.status, options:  [.new, .old], changeHandler: { (playerItem, change) in
            if playerItem.status == .readyToPlay {
                if let duration = self.player.currentItem?.duration {
                    globalAudioViewController?.audioSlider.minimumValue = 0
                    globalAudioViewController?.audioSlider.maximumValue = Float(CMTimeGetSeconds(duration))
                }
            }
        })
        // Associate the player item with the player
        player = AVPlayer(playerItem: playerItem)
    }
    
    func downloadAudio(url: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let downloadGroup = DispatchGroup()
            downloadGroup.enter()
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileURL = documentsURL.appendingPathComponent("\(url).mp3")
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            Alamofire.download(url, to: destination).response { response in
                if response.error == nil {
                    if let dataUrl = response.destinationURL {
                        self.audioDownloadUrl = dataUrl
                    }
                    downloadGroup.leave()
                }
            }
            downloadGroup.wait()
            downloadGroup.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
    }
    
    @objc func updateSlider() {
        if (haveAudioBeenStarted) {
            if let currentTime = player.currentItem?.currentTime() {
                globalAudioViewController?.audioSlider.value = Float(CMTimeGetSeconds(currentTime))
            }
        }
    }
}
