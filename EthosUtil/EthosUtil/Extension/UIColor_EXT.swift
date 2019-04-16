//
//  UIColor_EXT.swift
//  EthosUtil
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension UIColor {
    
    private static func extractComponent(argb: UInt64, offset: Int) -> CGFloat {
        return CGFloat((argb >> offset) & 0xFF) / 255
    }
    
    /**
     This constructor lets you to create a UIColor using an 0xAARRGGBB integer
     
     - parameters:
        - argb: 0xAARRGGBB UInt64
        - defaultAlpha: The value for the alpha channel that should be used should that information be missing from the
                        hex string
     
     eg. UIColor(rgb: 0x88FFFFFF)
     */
    convenience init(argb: UInt64, defaultAlpha: CGFloat = 1) {
        var alpha = UIColor.extractComponent(argb: argb, offset: 24)
        alpha = (alpha > 0) ? alpha : defaultAlpha
        let red = UIColor.extractComponent(argb: argb, offset: 16)
        let green = UIColor.extractComponent(argb: argb, offset: 8)
        let blue = UIColor.extractComponent(argb: argb, offset: 0)
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    /**
     This constructor lets you to create a UIColor using a hex string.
     
     eg.
     - UIColor(rgb: "0x88FFFFFF")
     - UIColor(rgb: "#FFFFFF")
     
     - parameters:
        - hexString: #AARRGGBB hex string
        - defaultAlpha: The value for the alpha channel that should be used should that information be missing from the
                        hex string
     */
    convenience init?(hexString: String, defaultAlpha: CGFloat = 1) {
        let scanner = Scanner(string: hexString
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "0x", with: "")
            .uppercased())
        
        
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {
            return nil
        }
        
        self.init(argb: hexNumber, defaultAlpha: defaultAlpha)
    }
    
    /**
     This method converts a CGColor to an UInt64
     
     - parameters:
        - includeAlpha: This parameter determines whether the alpha component should be included. Defaults to true
     
     - returns: an 0xRRGGBB or 0xAARRGGBB masked integer
     */
    func toUInt64(includeAlpha: Bool = true) -> UInt64 {
        return self.cgColor.toUInt64(includeAlpha: includeAlpha)
    }
    
    /**
     This method converts a CGColor to an RBG string.
     
     - parameters:
         - includeAlpha: This parameter determines whether the alpha component should be included. Defaults to true
         - prefix: This parameter determines the string prefix. Defaults to #
     
     - returns: a #RRGGBB or #AARRGGBB formatted string
     */
    func toString(includeAlpha: Bool = true, prefix: String = "#") -> String {
        return self.cgColor.toString(includeAlpha: includeAlpha, prefix: prefix)
    }
    
    
}
