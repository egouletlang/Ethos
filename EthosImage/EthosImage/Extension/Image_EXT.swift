//
//  Image_EXT.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/19/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension UIImage {
    
    var shortestEgde: CGFloat {
        return (self.size.width < self.size.height) ? self.size.width : self.size.height
    }
    
    var longestEgde: CGFloat {
        return (self.size.width < self.size.height) ? self.size.height : self.size.width
    }
    
    var bounds: CGRect {
        return CGRect(origin: CGPoint.zero, size: self.size)
    }
    
    func circleCrop(radius: CGFloat = 1) -> UIImage? {
        return ImageHelper.circleCrop(img: self, radius: radius)
    }
    
    func addColor(background: UIColor?) -> UIImage? {
        return ImageHelper.addBackgroundColor(img: self, color: background)
    }
    
    func addColor(mask: UIColor?) -> UIImage? {
        return ImageHelper.addColorMask(img: self, color: mask)
    }
}
