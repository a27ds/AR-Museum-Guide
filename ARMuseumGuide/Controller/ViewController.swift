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
import SVProgressHUD

var globalViewController: ViewController?

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var audioViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var closeButton: UIImageView!
    
    let impact = UINotificationFeedbackGenerator()
    let configuration = ARImageTrackingConfiguration()
    
    let screenSize = UIScreen.main.bounds
    
    let paintings = Paintings()
    var isInfoViewHidden = true
    var isAudioViewHidden = true
    var referenceImageName = ""
    var currentPaintingName = ""
    var currentArtistName = ""
    var activeNode: SCNNode!
    var lastPaintingThatBeenLoaded: String?
    
    @objc func closeButtonTapped(gesture: UIGestureRecognizer) {
        if (gesture.view as? UIImageView) != nil {
            hideOrShowInfoView()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfInternetAlert()
        globalViewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateAudioIconToPlay(_:)), name: Notification.Name(rawValue: "updateAudioIconToPlay"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAudioIconToPause(_:)), name: Notification.Name(rawValue: "updateAudioIconToPause"), object: nil)
        globalInfoViewController?.setTextInInfoView(paintingName: "", artistName: "", infoText: "")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped(gesture:)))
        closeButton.addGestureRecognizer(tapGesture)
        closeButton.isUserInteractionEnabled = true
        infoViewHeight.constant = screenSize.height * 0.1
        audioViewHeight.constant = 0.0
        closeButton.alpha = 0.0
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        getInfoFromFirebase {
            self.downloadphotos(completion: self.setAR)
        }
    }
    
    @objc func updateAudioIconToPlay(_ notification: Notification) {
        let rootNode = sceneView.scene.rootNode
        let audioButtonNode = rootNode.childNode(withName: "audioPlane", recursively: true)
        if let image = UIImage(named: "play-button") {
            audioButtonNode?.geometry?.firstMaterial?.diffuse.contents = image
        }
    }
    
    @objc func updateAudioIconToPause(_ notification: Notification) {
        let rootNode = sceneView.scene.rootNode
        let audioButtonNode = rootNode.childNode(withName: "audioPlane", recursively: true)
        if let image = UIImage(named: "pause-button") {
            audioButtonNode?.geometry?.firstMaterial?.diffuse.contents = image
        }
    }
    
    func hideOrShowAudioView() {
        if (isAudioViewHidden) {
            isAudioViewHidden = false
            audioViewHeight.constant = screenSize.height * 0.1
            // make check in audioviewcontroller what that will be showned.. audio or TTS
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            isAudioViewHidden = true
            audioViewHeight.constant = 0.0
            // make check in audioviewcontroller what that will be showned.. audio or TTS
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideOrShowInfoView() {
        if (isInfoViewHidden) {
            isInfoViewHidden = false
            
            infoViewHeight.constant = screenSize.height * 0.7
            globalInfoViewController?.hideOrShowInfoText()
            UIView.animate(withDuration: 0.5) {
                self.closeButton.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        } else {
            isInfoViewHidden = true
            infoViewHeight.constant = screenSize.height * 0.1
            globalInfoViewController?.hideOrShowInfoText()
            UIView.animate(withDuration: 0.5) {
                self.closeButton.alpha = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func getInfoFromFirebase(completion: @escaping () -> Void) {
        let db = Database.database().reference().child("exhibitions").child("art")
        db.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                self.paintings.artList.append(Art(snapshot: child))
            }
            completion()
        }
    }
    
    func downloadphotos(completion: @escaping () -> Void) {
        SVProgressHUD.show(withStatus: "Downloading Database")
        DispatchQueue.global(qos: .userInitiated).async {
            let downloadGroup = DispatchGroup()
            for art in self.paintings.artList {
                downloadGroup.enter()
                let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent("\(art.paintingName).jpg")
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                Alamofire.download(art.imageUrl, to: destination).response { response in
                    if response.error == nil, let imagePath = response.destinationURL?.path {
                        self.paintings.UIImageToArImage(imagePath: imagePath, imageName: art.paintingName, imageWidth: art.width)
                        
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
        configuration.trackingImages = paintings.arPaintingList
        self.configuration.maximumNumberOfTrackedImages = 1
        SVProgressHUD.showSuccess(withStatus: "Imagerecognizer active")
        self.sceneView.session.run(self.configuration)
    }
    
    func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func checkIfInternetAlert() {
        if isConnectedToInternet() {
            print("You have the Internetz!")
        } else {
            print("Pity the fool!")
            SVProgressHUD.setMaximumDismissTimeInterval(7)
            SVProgressHUD.showError(withStatus: "You need to have an active internet connection to use this app")
            SVProgressHUD.setMaximumDismissTimeInterval(1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        var newNode = SCNNode()
        runHapticFeedback()
        if let imageAnchor = anchor as? ARImageAnchor {
            newNode = createChildNodesToTheArt(node: newNode, imageAnchor: imageAnchor)
            activeNode = newNode
        }
        return newNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            if (!imageAnchor.isTracked) {
                sceneView.session.remove(anchor: anchor)
                lastPaintingThatBeenLoaded = anchor.name
            }
        }
    }
    
    func createChildNodesToTheArt(node: SCNNode, imageAnchor: ARImageAnchor) -> SCNNode {
        for art in paintings.artList {
            if (art.paintingName == imageAnchor.referenceImage.name) {
                referenceImageName = imageAnchor.referenceImage.name!
                currentArtistName = art.artistName
                currentPaintingName = art.paintingName
                if (referenceImageName != lastPaintingThatBeenLoaded && (globalAudioViewController?.haveAudioBeenStarted)!) {
                    DispatchQueue.main.async {
                        globalAudioViewController?.stopAudio()
                    }
                } else if ( referenceImageName != lastPaintingThatBeenLoaded && (globalAudioViewController?.haveTextToSpeechBeenStarted)!) {
                    DispatchQueue.main.async {
                        globalAudioViewController?.stopTextToSpeech()
                    }
                }
                node.addChildNode(createArtNode(imageAnchor: imageAnchor))
                node.addChildNode(createTextNode(imageAnchor: imageAnchor, artist: art.artistName, paintingName: art.paintingName, scale: 0.001))
                node.addChildNode(createInfoNode(imageAnchor: imageAnchor, scale: 0.1))
                node.addChildNode(createAudioNode(imageAnchor: imageAnchor, scale: 0.1))
                node.name = art.paintingName
            }
        }
        return node
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
    
    func whenArtPlaneGetClicked() {
        for art in paintings.artList {
            if (art.paintingName == referenceImageName) {
                if (!globalAudioViewController!.haveTextToSpeechBeenStarted && art.audioUrl.isEmpty) {
                    globalAudioViewController!.startTextToSpeech(art.infotextEn)
                    hideOrShowAudioView()
                } else if (!globalAudioViewController!.haveAudioBeenStarted && !art.audioUrl.isEmpty) {
                    globalAudioViewController!.streamAudio(Url: art.audioUrl)
                    hideOrShowAudioView()
                } else {
                    if (art.audioUrl.isEmpty) {
                        globalAudioViewController!.pauseOrPlayTextToSpeech()
                    } else {
                        globalAudioViewController!.pauseOrPlayAudio()
                    }
                }
            }
        }
    }
    
    func whenInfoPlaneGets() {
        if (isInfoViewHidden) {
            for art in paintings.artList {
                if (art.paintingName == referenceImageName) {
                    globalInfoViewController?.setTextInInfoView(paintingName: art.paintingName, artistName: art.artistName, infoText: art.infotextEn)
                    hideOrShowInfoView()
                }
            }
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
                whenArtPlaneGetClicked()
                break
            case "infoPlane":
                print("infoPlane")
                whenInfoPlaneGets()
                break
            default:
                break
            }
        }
    }
}
