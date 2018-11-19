//
//  MenuViewController.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-11-19.
//  Copyright © 2018 a27. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet var MenuView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutMenuView()
        
        
        
    }
    
    func layoutMenuView() {
        let path = UIBezierPath(ovalIn: CGRect(x: MenuView.frame.size.width/2 - MenuView.frame.size.height/2,
                                               y: 0.0,
                                               width: MenuView.frame.size.height,
                                               height: MenuView.frame.size.height))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        MenuView.layer.mask = maskLayer
        MenuView.backgroundColor = UIColor.black
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
