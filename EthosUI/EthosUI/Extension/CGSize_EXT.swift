//
//  CGSize_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension CGSize {
    
    static var maxSize: CGSize {
        return CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    }
    
    func addPadding(padding: Rect<CGFloat>) -> CGSize {
        return CGSize(width: self.width + padding.left + padding.right,
                      height: self.height + padding.top + padding.bottom)
    }
    
    func removePadding(padding: Rect<CGFloat>) -> CGSize {
        return CGSize(width: self.width - padding.left - padding.right,
                      height: self.height - padding.top - padding.bottom)
    }
    
}
