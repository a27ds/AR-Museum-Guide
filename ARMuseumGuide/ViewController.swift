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
            let artPlane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            artPlane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.0)
            let artPlaneNode = SCNNode(geometry: artPlane)
            // Change the eulerAngle on the artPlaneNode because it's otherwise standing up on the picture.
            // so the change is on x and I using the .pi (180°) but half that and negative to get it to rotate 90° on the x ax.
            artPlaneNode.eulerAngles.x = -.pi / 2
            artPlaneNode.name = "artPlane"
            
            let audioPlane = SCNPlane(width: 0.1, height: 0.1)
            audioPlane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 1.0)
            let audioPlaneNode = SCNNode(geometry: audioPlane)
            audioPlaneNode.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 2) + Float(-audioPlane.height / 2) // top position
            //                        audioPlaneNode.position.z = Float(imageAnchor.referenceImage.physicalSize.height / 2) + Float(audioPlane.height / 2) // bottom position
            //                        audioPlaneNode.position.x = Float(-imageAnchor.referenceImage.physicalSize.width / 2) + Float(-audioPlane.width / 2) // left position
            //                        audioPlaneNode.position.x = Float(imageAnchor.referenceImage.physicalSize.width / 2) + Float(audioPlane.width / 2) + 0.005 // right position
            audioPlaneNode.eulerAngles.x = -.pi / 2
            audioPlaneNode.name = "audioPlane"
            node.addChildNode(audioPlaneNode)
            node.addChildNode(artPlaneNode)
            
        }
        return node
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
                
            default:
                break
            }
        }
    }
    
}
