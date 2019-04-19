//
//  CircleCropTransform.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/18/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class CircleCropTransform: BaseImageTransform {
    
    public init(radius: CGFloat = 1) {
        self.radius = radius
    }
    
    // MARK: - Variables -
    private var radius: CGFloat
    
    // MARK: - Parent Methods -
    override open func modifyKey(key: String) -> String {
        return "\(key)-circle-\(radius)"
    }
    
    override open func transform(img: UIImage?) -> UIImage? {
        return img?.circleCrop(radius: radius)
    }
}
