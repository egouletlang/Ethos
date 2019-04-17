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
    
    open class func parse(_ raw: String?, textSize: CGFloat? = nil, textColor: String? = nil,
                          allowLinks: Bool = true) -> LabelDescriptor? {
        
        let li = LabelDescriptor()
        
        guard let r = raw else {
            return li
        }
        
        let parser = TagParser().with(textSize: textSize)
                                .with(textColorStr: textColor)
                                .with(supportLinks: allowLinks)
        
        let (attr, links) = parser.parse(raw: r)
        
        li.attr = attr
        
        if (allowLinks) {
            li.links = links
        }
        
        return li
    }
}
