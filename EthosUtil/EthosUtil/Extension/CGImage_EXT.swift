//
//  CGImage_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension CGImage {
    
    /**
     This method determines if an image uses pixels with an alpha channel
     
     - returns: true if the image uses pixels with an alpha channel
     */
    func hasAlpha() -> Bool {
        return self.alphaInfo != .none
    }
}
