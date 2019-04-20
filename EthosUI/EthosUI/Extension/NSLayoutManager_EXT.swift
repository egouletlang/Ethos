//
//  NSLayoutManager_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

extension NSLayoutManager {
    
    var glyphRange: Range<Int> {
        return 0 ..< self.numberOfGlyphs
    }
    
    var height: CGFloat {
        
        var ret: CGFloat = 0
        var prevX = CGFloat.nan
        
        self.glyphRange.map() { self.location(forGlyphAt: $0) }
            .forEach { (point) in
                if prevX == CGFloat.nan || point.x < prevX {
                    ret += point.y
                }
                prevX = point.x
            }
        
        return ret
    }
    
}
