//
//  CGRect_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension CGRect {
    
    func insetBy(padding: Rect<CGFloat>) -> CGRect {
        var rect = self.insetBy(dx: (padding.left + padding.right) / 2, dy: (padding.top + padding.bottom) / 2)
        rect.origin = CGPoint(x: padding.left, y: padding.top)
        return rect
    }
    
}
