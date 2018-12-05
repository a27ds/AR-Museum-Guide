//
//  ViewController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-10-31.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Firebase
import AVFoundation
import Alamofire

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var infoViewBottom: NSLayoutConstraint!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
    
    let impact = UINotificationFeedbackGenerator()
    let configuration = ARImageTrackingConfiguration()
    let screenRect = UIScreen.main.bounds
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var infoVCHidden: Bool = true
    public static let paintings = Paintings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoViewHeight.constant = screenHeight / 1.3
        infoViewBottom.constant = -(screenHeight / 1.3)
        
        
        // Set the view's delegate
        sceneView.delegate = self
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        screenWidth = screenRect.size.width
        screenHeight = screenRect.size.height
        
//        showOrHideInfoVC()
        
        getInfoFromFirebase {
            self.downloadphotos(completion: self.setAR)
        }
    }
    
    func getInfoFromFirebase(completion: @escaping () -> Void) {
        let db = Database.database().reference().child("exhibitions").child("art")
        db.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                ViewController.paintings.artList.append(Art(snapshot: child))
            }
            completion()
        }
    }
    
    func downloadphotos(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let downloadGroup = DispatchGroup()
            
            for art in ViewController.paintings.artList {
                downloadGroup.enter()
                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent("\(art.paintingName).jpg")
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                Alamofire.download(art.imageUrl, to: destination).response { response in
                    if response.error == nil, let imagePath = response.destinationURL?.path {
                        ViewController.paintings.UIImageToArImage(imagePath: imagePath, imageName: art.paintingName, imageWidth: art.width)
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
    
    func setAR() {
        configuration.trackingImages = ViewController.paintings.arPaintingList
        self.configuration.maximumNumberOfTrackedImages = 2
        print("Images Successfully Added")
        self.sceneView.session.run(self.configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        // Create a session configuration
        //        let configuration = ARImageTrackingConfiguration()
        // Creating the imageToTrack, if successfull then config the session
        //        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Art Resources", bundle: Bundle.main) {
        //            configuration.trackingImages = imageToTrack
        //            configuration.maximumNumberOfTrackedImages = 2
        //            print("Images Successfully Added")
        //        }
        //        // Run the view's session
        //        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func runHapticFeedback() {
        DispatchQueue.main.async {
            self.impact.notificationOccurred(.success)
        }
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        var node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            runHapticFeedback()
            node = createChildNodesToTheArt(node: node, imageAnchor: imageAnchor)
        }
        return node
    }
    
    func createChildNodesToTheArt(node: SCNNode, imageAnchor: ARImageAnchor) -> SCNNode {
        for art in ViewController.paintings.artList {
            if (art.paintingName == imageAnchor.referenceImage.name) {
                
                node.addChildNode(createArtNode(imageAnchor: imageAnchor))
                node.addChildNode(createTextNode(imageAnchor: imageAnchor, artist: art.artistName, paintingName: art.paintingName, scale: 0.001))
                node.addChildNode(createInfoNode(imageAnchor: imageAnchor, scale: 0.1))
                if (!art.audioUrl.isEmpty) {
                    node.addChildNode(createAudioNode(imageAnchor: imageAnchor, scale: 0.1))
                }
            }
        }
        return node
    }
    
//    func artArea(art: Art) -> CGFloat{
//        let widthInCm = art.width * 10
//        let heightInCm = art.height * 10
//        print(widthInCm)
//        print(heightInCm)
//        let area = widthInCm * heightInCm
//        print("Area of \(art.paintingName) is: \(area)")
//        let scale = CGFloat(area * 0.05)
//        print("scale: \(scale)")
//        return scale
//    }
    
    func textToSpeech() {
        let string = "Referenced"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    func createArtNode(imageAnchor: ARImageAnchor) -> SCNNode {
        let artPlane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        artPlane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
        let artPlaneNode = SCNNode(geometry: artPlane)
        // Change the eulerAngle on the artPlaneNode because it's otherwise standing up on the picture.
        // so the change is on x and I using the .pi (180°) but half that and negative to get it to rotate 90° on the x ax.
        artPlaneNode.eulerAngles.x = -.pi / 2
        artPlaneNode.name = "artPlane"
        return artPlaneNode
    }
    
    func createAudioNode(imageAnchor: ARImageAnchor, scale: CGFloat) -> SCNNode {
        let audioPlane = SCNPlane(width: scale, height: scale)
        // add image to audio plane
        if let image = UIImage(named: "play-button") {
            audioPlane.firstMaterial?.diffuse.contents = image
        }
        let audioNode = SCNNode(geometry: audioPlane)
        audioNode.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 2) + (Float(-audioPlane.height / 2) * 2) // top position
        //                        audioPlaneNode.position.x = Float(-imageAnchor.referenceImage.physicalSize.width / 2) + Float(-audioPlane.width / 2) // left position
        audioNode.eulerAngles.x = -.pi / 2
        audioNode.name = "audioPlane"
        return audioNode
    }
    
    func createInfoNode(imageAnchor: ARImageAnchor, scale: CGFloat) -> SCNNode {
        let infoPlane = SCNPlane(width: scale, height: scale)
        if let image = UIImage(named: "information-button") {
            infoPlane.firstMaterial?.diffuse.contents = image
        }
        let infoNode = SCNNode(geometry: infoPlane)
        infoNode.position.x = Float(imageAnchor.referenceImage.physicalSize.width / 2) + (Float(infoPlane.width / 2) * 2) // right position
        infoNode.eulerAngles.x = -.pi / 2
        infoNode.name = "infoPlane"
        return infoNode
    }
    
    func createTextNode(imageAnchor: ARImageAnchor, artist: String, paintingName: String, scale: Float) -> SCNNode {
        let artistText = SCNText(string: artist, extrusionDepth: 0.1)
        artistText.font = UIFont(name: "HelveticaNeue-Thin", size: 60)
        let paintingText = SCNText(string: paintingName, extrusionDepth: 0.1)
        paintingText.font = UIFont(name: "HelveticaNeue-Thin", size: 60)
        
        //Create material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        artistText.materials = [material]
        paintingText.materials = [material]
        
        //Create Node object
        let node = SCNNode()
        let artistTextNode = SCNNode()
        artistTextNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        artistTextNode.geometry = artistText
        
        //Create Node object
        let paintingNameTextNode = SCNNode()
        paintingNameTextNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        paintingNameTextNode.geometry = paintingText
        
        // Center the text by changingn the pivot point in the text nodes
        centerTextAndFixAngles(node: artistTextNode)
        centerTextAndFixAngles(node: paintingNameTextNode)
        
        // set the height and halfvalue of text
        artistTextNode.position.z = Float(imageAnchor.referenceImage.physicalSize.height / 2) - ((artistText.boundingBox.min.z / 2) * 2) // bottom position
        artistTextNode.name = "Text"
        
        paintingNameTextNode.position = SCNVector3Make(0, 0, artistTextNode.position.z - ((artistText.boundingBox.min.z / 2) * 3))
        paintingNameTextNode.name = "Text"
        
        node.addChildNode(artistTextNode)
        node.addChildNode(paintingNameTextNode)
        
        return node
    }
    
    func centerTextAndFixAngles (node: SCNNode) {
        let (minVec, maxVec) = node.boundingBox
        node.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        
        node.eulerAngles.x = -.pi / 2
    }
    
    func showOrHideInfoVC() {
        if (infoVCHidden) {
            infoViewBottom.constant = screenHeight / 1.3
            
            infoVCHidden = false
            mainView.isUserInteractionEnabled = false
        } else {
            infoViewBottom.constant = -(screenHeight / 1.3)
            infoVCHidden = true
            mainView.isUserInteractionEnabled = true
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView),
            let hitTestNode = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node else { return }
        
        if let artID = hitTestNode.name {
            switch (artID) {
                
            case "artPlane":
                print("artPlane")
                break
                
            case "audioPlane":
                print("audioPlane")
                textToSpeech()
                break
                
            case "infoPlane":
                print("infoPlane")
                showOrHideInfoVC()
                break
                
            default:
                break
            }
        }
    }
    
    //    func getDataFromFireStore() {
    //        //            testkod
    //
    //        let db = Firestore.firestore()
    //        db.collection("exhibitions").getDocuments() { (querySnapshot, err) in
    //            self.docRef.getDocument { (document, error) in
    //                if let document = document, document.exists {
    //                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
    //                    print("Document data: \(dataDescription)")
    //                } else {
    //                    print("Document does not exist")
    //                }
    //            }
    //            //                if let err = err {
    //            //                    print("Error getting documents: \(err)")
    //            //                } else if let querySnapshot = querySnapshot {
    //            //                    for document in querySnapshot.documents {
    //            //                        print("\(document.documentID) => \(document.data())")
    //            //                    }
    //            //
    //            //                }
    //        }
    //
    //        //            db.collection("cities").getDocuments() { (querySnapshot, err) in
    //        //                if let err = err {
    //        //                    print("Error getting documents: \(err)")
    //        //                } else {
    //        //                    for document in querySnapshot!.documents {
    //        //                        print("\(document.documentID) => \(document.data())")
    //        //                    }
    //        //                }
    //        //            }
    //
    //
    //        //            let dataToSave : [String: Any] = ["test": 1234, "name": "andy"]
    //        //            docRef.setData(dataToSave) { (error) in
    //        //                if let error = error {
    //        //                    print("not compute: \(error.localizedDescription)")
    //        //                } else {
    //        //                    print("data been saved")
    //        //                }
    //        //            }
    //
    //
    //        //            testkod
    //    }
    //
    //}
    //
    ////    override func viewWillTransition(to size: CGSize,   with coordinator:    UIViewControllerTransitionCoordinator) {
    ////
    ////        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
    ////
    ////            let orient = UIApplication.shared.statusBarOrientation
    ////
    ////            switch orient {
    ////            case .portrait:
    ////                print("Portrait")
    ////                self.applyportraitConstraint()
    ////                break
    ////            // Do something
    ////            default:
    ////                print("LandScape")
    ////                // Do something else
    ////                self.applyLandScapeConstraint()
    ////                break
    ////            }
    ////        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
    ////            print("rotation completed")
    ////        })
    ////        super.viewWillTransition(to: size, with: coordinator)
    ////    }
}
