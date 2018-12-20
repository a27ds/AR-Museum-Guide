//
//  AudioViewController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-12-16.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Alamofire

var globalAudioViewController: AudioViewController?

class AudioViewController: UIViewController {
    
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
    
    @IBOutlet weak var audioSlider: UISlider!
    @IBOutlet weak var playAndPause: UIImageView!
    @IBOutlet weak var stopButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globalAudioViewController = self
        haveAudioBeenStarted = false
        isAudioPaused = false
        haveTextToSpeechBeenStarted = false
        isTextToSpeechPaused = false
        let playPauseTapGesture = UITapGestureRecognizer(target: self, action: #selector(playPauseButtonTapped(gesture:)))
        playAndPause.addGestureRecognizer(playPauseTapGesture)
        playAndPause.isUserInteractionEnabled = true
        let stopTapGesture = UITapGestureRecognizer(target: self, action: #selector(stopButtonTapped(gesture:)))
        stopButton.addGestureRecognizer(stopTapGesture)
        stopButton.isUserInteractionEnabled = true
        if let image = UIImage(named: "thumb-slider") {
            audioSlider.setThumbImage(image, for: .normal)
            audioSlider.setThumbImage(image, for: .highlighted)
        }
        audioSlider.value = 0.0
        audioSlider.isHidden = true
    }
    
    @objc func playPauseButtonTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            if (haveAudioBeenStarted) {
                pauseOrPlayAudio()
            } else {
                pauseOrPlayTextToSpeech()
            }
        }
    }
    
    @objc func stopButtonTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            if (haveAudioBeenStarted) {
                stopAudio()
            } else {
                stopTextToSpeech()
            }
        }
    }
    
    @IBAction func changeAudioTime(_ sender: Any) {
        player.seek(to: CMTimeMakeWithSeconds(Float64(audioSlider.value), preferredTimescale: (player.currentItem!.duration.timescale)))
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        stopAudio()
    }
    
    func startTextToSpeech(_ text: String) {
        if (haveAudioBeenStarted) {
            stopAudio()
            audioSlider.isHidden = true
        }
        utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
        changePlayIconInAudioViewToPause(true)
        isTextToSpeechPaused = false
        haveTextToSpeechBeenStarted = true
    }
    
    func stopTextToSpeech() {
        synth.stopSpeaking(at: .immediate)
        haveTextToSpeechBeenStarted = false
        changePlayIconInAudioViewToPause(false)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
        globalViewController?.hideOrShowAudioView()
    }
    
    func pauseOrPlayTextToSpeech() {
        if (isTextToSpeechPaused) {
            synth.continueSpeaking()
            changePlayIconInAudioViewToPause(true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
            isTextToSpeechPaused = false
        } else {
            synth.pauseSpeaking(at: .word)
            changePlayIconInAudioViewToPause(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
            isTextToSpeechPaused = true
        }
    }
    
    func pauseOrPlayAudio() {
        if (isAudioPaused) {
            print("isPlaying")
            player.play()
            changePlayIconInAudioViewToPause(true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
            isAudioPaused = false
        } else {
            print("isPaused")
            player.pause()
            changePlayIconInAudioViewToPause(false)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
            isAudioPaused = true
        }
    }
    
    func stopAudio() {
        timer?.invalidate()
        player.pause()
        changePlayIconInAudioViewToPause(false)
        player = nil
        globalViewController?.hideOrShowAudioView()
        haveAudioBeenStarted = false
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
        DispatchQueue.main.async {
            //need to do the change in an dispatchqueue, because the function is called from another thread then the main thread
            self.audioSlider.value = 0.0
        }
    }
    
    func streamAudio(Url: String) {
        if (haveTextToSpeechBeenStarted) {
            stopTextToSpeech()
        }
        audioSlider.isHidden = false
        
        downloadAudio(url: Url) {
            if let url = self.audioDownloadUrl {
                self.playerItem = AVPlayerItem(url: url)
                self.player = AVPlayer(playerItem: self.playerItem)
            }
            self.audioSlider.value = 0.0
            self.prepareToPlay()
            self.player.play()
            self.changePlayIconInAudioViewToPause(true)
            self.timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            self.isAudioPaused = false
            self.haveAudioBeenStarted = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        }
    }
    
    func changePlayIconInAudioViewToPause(_ isPauseVisible: Bool) {
        DispatchQueue.main.async {
            if (isPauseVisible) {
                if let image = UIImage(named: "pause-button") {
                    self.playAndPause.image = image
                }
            } else {
                if let image = UIImage(named: "play-button") {
                    self.playAndPause.image = image
                }
            }
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
                    self.audioSlider.minimumValue = 0
                    self.audioSlider.maximumValue = Float(CMTimeGetSeconds(duration))
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
                audioSlider.value = Float(CMTimeGetSeconds(currentTime))
            }
        }
    }
}
