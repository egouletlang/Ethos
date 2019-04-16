//
//  CGColor_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGColor {
    
    /**
     This property returns an array of intensity values for the color components, ranging from 0 to 1
     
     - returns: a list of intensity values for [alpha, red, green, blue]
     */
    var floatComponents: [CGFloat] {
        var ret = [CGFloat](repeating: 0, count: 4)
        
        guard let components = self.components else {
            return ret
        }
        
        for (index, component) in components.enumerated() {
            if index < 4 {
                ret[index] = component
            }
        }
        
        return ret
    }
    
    /**
     This property returns an array of intensity values for the color components, ranging from 0 to 255
     
     - returns: a list of intensity values for [alpha, red, green, blue]
     */
    var intComponents: [UInt64] {
        return self.floatComponents.map() { UInt64($0 * 255) }
    }
    
    /**
     This method converts a CGColor to an UInt64
     
     - parameters:
        - includeAlpha: This parameter determines whether the alpha component should be included. Defaults to true
     
     - returns: an 0xRRGGBB or 0xAARRGGBB masked integer
     */
    func toUInt64(includeAlpha: Bool = true) -> UInt64 {
        var ret: UInt64 = 0
        
        ret |= intComponents[0]
        ret |= intComponents[1] << 8
        ret |= intComponents[2] << 16
        
        if includeAlpha {
            ret |= intComponents[3] << 24
        }
        
        return ret
    }
    
    /**
     This method converts a CGColor to an RBG string.
     
     - parameters:
        - includeAlpha: This parameter determines whether the alpha component should be included. Defaults to true
        - prefix: This parameter determines the string prefix. Defaults to #
     
     - returns: a #RRGGBB or #AARRGGBB formatted string
     */
    func toString(includeAlpha: Bool = true, prefix: String = "#") -> String {
        let uintColor = self.toUInt64(includeAlpha: includeAlpha)
        return String(format: "%@%X", prefix, uintColor)
    }
    
}
