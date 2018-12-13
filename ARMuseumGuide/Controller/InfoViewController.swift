//
//  MenuViewController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-11-19.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

var globalInfoViewController: InfoViewController?

class InfoViewController: UIViewController {
    
    @IBOutlet var MenuView: UIView!
    @IBOutlet weak var paintingNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    var isInfoTexthidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globalInfoViewController = self
        layoutMenuView()
    }
    
    func layoutMenuView() {
        let path = UIBezierPath(ovalIn: CGRect(x: MenuView.frame.size.width/2 - MenuView.frame.size.height/2, y: 0.0, width:                MenuView.frame.size.height, height: MenuView.frame.size.height))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        MenuView.layer.mask = maskLayer
        MenuView.backgroundColor = UIColor.black
    }
    
    public func setTextInInfoView(paintingName: String, artistName: String, infoText: String) -> Void {
        infoTextView.text = ""
        paintingNameLabel.text = ""
        artistNameLabel.text = ""
        infoTextView.text = infoText
        paintingNameLabel.text = paintingName
        artistNameLabel.text = artistName
        infoTextView.alpha = 0.0
        paintingNameLabel.alpha = 0.0
        artistNameLabel.alpha = 0.0
    }
    
    func hideOrShowInfoText() {
        if (isInfoTexthidden) {
            isInfoTexthidden = false
            UIView.animate(withDuration: 0.7) {
                self.infoTextView.alpha = 1.0
                self.paintingNameLabel.alpha = 1.0
                self.artistNameLabel.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        } else {
            isInfoTexthidden = true
            
            UIView.animate(withDuration: 0.5) {
                self.infoTextView.alpha = 0.0
                self.paintingNameLabel.alpha = 0.0
                self.artistNameLabel.alpha = 0.0
                self.view.layoutIfNeeded()
            }
        }
    }
}
