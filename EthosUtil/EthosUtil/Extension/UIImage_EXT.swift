//
//  UIImage_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension UIImage {
    
    /**
     This method returns a scaled version of the current image
     
     - note: the scaling algorith does not preserve the aspect ratio and works similar to .scaleToFill
     
     - parameters:
        - newSize: desired size
     
     - returns: a scaled image
     */
    private func resizedImage(newSize: CGSize) -> UIImage? {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /**
     This method returns a scaled version of the current image that "fits" in the provided size
     
     - note: the scaling algorithm preserves the aspect ratio and works similar to .aspectFit
     
     - parameters:
        - newSize: available size
     
     - returns: a scaled image
     */
    func resize(newSize: CGSize) -> UIImage? {
        let widthFactor = self.size.width / newSize.width
        let heightFactor = self.size.height / newSize.height
        
        var resizeFactor = widthFactor
        if self.size.height > self.size.width {
            resizeFactor = heightFactor
        }
        
        let scaledSize = CGSize(width: self.size.width / resizeFactor, height: self.size.height / resizeFactor)
        return resizedImage(newSize: scaledSize)
    }
    
    /**
     This method returns a scaled version of the current image that "fits" in the provided rect
     
     - note: the scaling algorithm preserves the aspect ratio and works similar to .aspectFit
     
     - parameters:
        - rect: available rect
     
     - returns: a scaled image
     */
    func resize(rect: CGRect) -> UIImage? {
        return self.resize(newSize: rect.size)
    }
    
    
}
