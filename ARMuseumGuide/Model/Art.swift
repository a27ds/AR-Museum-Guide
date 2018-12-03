//
//  Art.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-11-30.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import Firebase

class Art {
    var artistName: String
    var paintingName: String
    var height: Double
    var width: Double
    var infotextEn: String
    var audioUrl: String
    var imageUrl: String
    var videoUrl: String
    
    init(artistName: String, paintingName: String, height: Double, width: Double, infotextEn: String, audioUrl: String, imageUrl: String, videoUrl: String) {
        self.artistName = artistName
        self.paintingName = paintingName
        self.height = height
        self.width = width
        self.infotextEn = infotextEn
        self.audioUrl = audioUrl
        self.imageUrl = imageUrl
        self.videoUrl = videoUrl
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: Any]
        artistName = snapshotValue["artist-name"] as! String
        paintingName = snapshotValue["painting-name"] as! String
        height = snapshotValue["height"] as! Double
        width = snapshotValue["width"] as! Double
        infotextEn = snapshotValue["infotext-en"] as! String
        audioUrl = snapshotValue["link-audio"] as! String
        imageUrl = snapshotValue["link-image"] as! String
        videoUrl = snapshotValue["link-video"] as! String
    }
}
