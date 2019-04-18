//
//  CircleCropImageTransform.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/18/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class CircleCropImageTransform: BaseImageTransform {
    
    // MARK: - Constructor -
    public convenience init (radius: CGFloat) {
        self.init()
        self.radius = radius
    }
    
    // MARK: - Variables -
    private var radius: CGFloat = 1
    
    // MARK: - Parent Methods -
    override open func modifyKey(key: String) -> String {
        return "\(key)[\(radius)-circle]"
    }
    
    override open func transform(img: UIImage?) -> UIImage? {
        return ImageHelper.circleCrop(img: img, radius: radius)
    }
}
