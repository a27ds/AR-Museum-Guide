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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        // Creating the imageToTrack, if successfull then config the session
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Art Resources", bundle: Bundle.main) {
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 1
            print("Images Successfully Added")
        }
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        // added a white plane with 0.5 in alpha to see that imageTracking is working
        if let imageAnchor = anchor as? ARImageAnchor {
            node.addChildNode(createArtNode(imageAnchor: imageAnchor))
            node.addChildNode(createAudioNode(imageAnchor: imageAnchor))
            node.addChildNode(createTextNode(imageAnchor: imageAnchor))
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
    
    func createAudioNode(imageAnchor: ARImageAnchor) -> SCNNode {
        let audioPlane = SCNPlane(width: 0.1, height: 0.1)
        // add image to audio plane
        if let image = UIImage(named: "play-button") {
            audioPlane.firstMaterial?.diffuse.contents = image
        }
        let audioNode = SCNNode(geometry: audioPlane)
        audioNode.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 2) + Float(-audioPlane.height / 2) // top position
        //                        audioPlaneNode.position.z = Float(imageAnchor.referenceImage.physicalSize.height / 2) + Float(audioPlane.height / 2) // bottom position
        //                        audioPlaneNode.position.x = Float(-imageAnchor.referenceImage.physicalSize.width / 2) + Float(-audioPlane.width / 2) // left position
        //                        audioPlaneNode.position.x = Float(imageAnchor.referenceImage.physicalSize.width / 2) + Float(audioPlane.width / 2) + 0.005 // right position
        audioNode.eulerAngles.x = -.pi / 2
        audioNode.name = "audioPlane"
        print("audio:\(audioPlane.height)")
        return audioNode
    }
    
    func createTextNode(imageAnchor: ARImageAnchor) -> SCNNode {
        let text = SCNText(string: "Van Ghog", extrusionDepth: 0.1)
        text.font = UIFont(name: "HelveticaNeue-Thin", size: 60)
        
        //Create material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        text.materials = [material]
        
        //Create Node object
        let textNode = SCNNode()
        textNode.scale = SCNVector3(x:0.001, y:0.001, z: 0.001)
        textNode.geometry = text
        
        // Center the text by changingn the pivit point in the text nodes
        let (minVec, maxVec) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        
        textNode.eulerAngles.x = -.pi / 2
        
        // get the height and halfvalue of text
        let textHeight = Float(text.boundingBox.min.y)
        let roundedTextHeight = textHeight.rounded(.toNearestOrEven)
        let decimalMoveOnTextHeight = roundedTextHeight / 10
        
        textNode.position.z = Float(imageAnchor.referenceImage.physicalSize.height / 2) + decimalMoveOnTextHeight
        
        textNode.name = "Text"
        return textNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentTouchLocation = touches.first?.location(in: self.sceneView),
            let hitTestNode = self.sceneView.hitTest(currentTouchLocation, options: nil).first?.node else { return }
        
        if let artID = hitTestNode.name {
            switch (artID) {
                
            case "artPlane":
                print("bajs")
                break
                
            case "audioPlane":
                print("audioPlane")
                break
                
            case "Text":
                print("text")
                break
                
            default:
                break
            }
        }
    }
    
}
