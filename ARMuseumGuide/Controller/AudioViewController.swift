//
//  AudioViewController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-12-16.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

var globalAudioViewController: AudioViewController?

class AudioViewController: UIViewController {

    @IBOutlet weak var audioSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globalAudioViewController = self
        if let image = UIImage(named: "thumb-slider") {
            audioSlider.setThumbImage(image, for: .normal)
            audioSlider.setThumbImage(image, for: .highlighted)
        }
        audioSlider.value = 0.0
    }
    
    
    
    
//    @IBAction func changeAudioTime(_ sender: Any) {
//        audioSlider.
//
//    }
    

}
