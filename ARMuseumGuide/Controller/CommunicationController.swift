//
//  CommunicationController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-11-30.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

class CommunicationController {
    
    
    
    func getInfoFromFirebase() {
        let db = Database.database().reference().child("exhibitions").child("art")
        db.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                Paintings.artList.append(Art(snapshot: child))
            }
        }
    }
    
    func downloadphotos(completion: @escaping () -> Void) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("The_Scream.jpg")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        var urlString = [String]()
        urlString.append("https://firebasestorage.googleapis.com/v0/b/ar-museum-guide.appspot.com/o/The_Scream.jpg?alt=media&token=95d90ef1-59e7-410c-844d-503157e149e2")
        urlString.append("https://firebasestorage.googleapis.com/v0/b/ar-museum-guide.appspot.com/o/starry_night.jpg?alt=media&token=3901689a-7172-417c-ba41-d166954bafac")
        urlString.append("https://firebasestorage.googleapis.com/v0/b/ar-museum-guide.appspot.com/o/The_Enigma_of_William_Tell.jpg?alt=media&token=9f9ac714-deae-443f-bd6f-b25bb5356421")
        
        DispatchQueue.global(qos: .userInitiated).async {
            let downloadGroup = DispatchGroup()
            
            for url in urlString {
                downloadGroup.enter()
                Alamofire.download(url, to: destination).response { response in
                    if response.error == nil, let imagePath = response.destinationURL?.path {
                        ImageConverter.
                        downloadGroup.leave()
                    }
                }
            }
            downloadGroup.wait()
            downloadGroup.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
    }
    
    
    
}
