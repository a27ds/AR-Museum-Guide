//
//  Paintings.swift
//  ARMuseumGuide
//
//  Created by a27 on 2018-11-30.
//  Copyright © 2018 a27. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Paintings {
    public var artList = [Art]()
    public var arPaintingList = Set<ARReferenceImage>()
    var arImageUrl = [String]()
    
    public func UIImageToArImage (imagePath: String, imageName: String, imageWidth: Double) {
        let image = UIImage(contentsOfFile: imagePath)
        let imageToCIImage = CIImage(image: image!)
        //3. Then Convert The CIImage To A CGImage
        let cgImage = self.convertCIImageToCGImage(inputImage: imageToCIImage!)
        //4. Create An ARReference Image (Remembering Physical Width Is In Metres)
        let arImage = ARReferenceImage(cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: CGFloat(imageWidth))
        //5. Name The Image
        arImage.name = imageName
        arPaintingList.insert(arImage)
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
}

