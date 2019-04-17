//
//  TextHelper.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

open class TextHelper {
    
    // MARK: - Interface -
    
    /**
     Create a LabelDescriptor object for a markup string
     
     - parameters:
        - raw: This parameter is a string with style tags that should be formatted
        - textSize: This paramter represents the base text size that should be used while styling. If nil is set, the
                    module default will be used. Defaults to nil
        - textColor: This paramter represents the base text color that should be used while styling. If nil is set, the
                     color black will be used
        - allowLinks: This parameter determines whether the resulting LabelDescriptor will contain link information
     
     - returns: A LabelDescriptor containing a stylized attributed string and Link Information
     */
    open class func formatString(_ raw: String?, textSize: Int? = nil, textColor: String? = nil,
                                 allowLinks: Bool = true) -> LabelDescriptor? {
        
        let textSize = textSize ?? Int(EthosTextConfig.shared.regularFont.pointSize)
        
        let links = NSMutableArray()
        let linkLocations = NSMutableArray()
        let li = LabelDescriptor()
        li.attr = NSMutableAttributedString(string: "")
        
        if let _raw = raw {
            li.attr = AttributedStringCreator.build(_raw, Int32(textSize), links, linkLocations, textColor)
        }
        
        if allowLinks {
            for (link, location) in zip(links, linkLocations) {
                guard let urlString = link as? String, let url = URL(string: urlString) else { continue }
                guard let range = (location as AnyObject).rangeValue else { continue }
                
                li.links.set(url, range)
            }
        }
        return li
    }
}
