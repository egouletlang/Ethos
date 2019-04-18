//
//  BaseImageTransform.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/18/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class BaseImageTransform {
    
    open func modifyKey(key: String) -> String {
        return key
    }
    
    open func transform(img: UIImage?) -> UIImage? {
        return nil
    }
    
}
