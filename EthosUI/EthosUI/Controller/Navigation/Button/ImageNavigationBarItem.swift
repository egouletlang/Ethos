//
//  ImageNavigationBarItem.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class ImageNavigationBarItem: BaseNavigationBarItem {
    
    open func with(image: UIImage?) -> ImageNavigationBarItem {
        self.image = image
        return self
    }
    
    open func with(tint: UIColor?) -> ImageNavigationBarItem {
        self.tint = tint
        return self
    }
    
    open var image: UIImage?
    
    open var tint: UIColor?
    
    open override var button: UIBarButtonItem? {
        let button = UIButton(type: .custom)
        button.setImage(image, for: UIControl.State())
        button.addTarget(self.target, action: self.selector, for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        let ret = UIBarButtonItem(customView: button)
        ret.width = 20
        return ret
    }
    
}
