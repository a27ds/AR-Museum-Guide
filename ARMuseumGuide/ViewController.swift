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
        
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            if let pokeScene = SCNScene(named: "art.scnassets/stratocaster.scn") {
                if let pokeNode = pokeScene.rootNode.childNodes.first {
                    pokeNode.eulerAngles.x = .pi / 2
                    planeNode.addChildNode(pokeNode)
                }
            }
            node.addChildNode(planeNode)
            
            //            let planeUp = SCNPlane(width: 0.1, height: 0.1)
            //            planeUp.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 1.0)
            //            let planeUpNode = SCNNode(geometry: planeUp)
            //            planeUpNode.position.z = -Float(imageAnchor.referenceImage.physicalSize.height / 2) + Float(-planeUp.height / 2) // top position
            //            planeUpNode.position.z = Float(imageAnchor.referenceImage.physicalSize.height / 2) + Float(planeUp.height / 2) // bottom position
            //            planeUpNode.position.x = Float(-imageAnchor.referenceImage.physicalSize.width / 2) + Float(-planeUp.width / 2) // left position
            //            planeUpNode.position.x = Float(imageAnchor.referenceImage.physicalSize.width / 2) + Float(planeUp.width / 2) + 0.005 // right position
            //            planeUpNode.eulerAngles.x = -.pi / 2
            //            node.addChildNode(planeUpNode)
            
            
        }
        return node
    }
}
