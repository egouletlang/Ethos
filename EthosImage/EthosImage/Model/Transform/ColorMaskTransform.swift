//
//  ColorMaskTransform.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/19/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class ColorMaskTransform: BaseImageTransform {
    
    public init(color: String) {
        self.color = color
    }
    
    // MARK: - Variables -
    private var color: String
    
    // MARK: - Parent Methods -
    override open func modifyKey(key: String) -> String {
        return "\(key)-mask-\(color)"
    }
    
    override open func transform(img: UIImage?) -> UIImage? {
        return img?.addColor(mask: UIColor(hexString: color))
    }
}
