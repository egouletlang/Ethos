//
//  TextNavigationBarItem.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosText

open class TextNavigationBarItem: BaseNavigationBarItem {
    
    open func with(label: String?) -> TextNavigationBarItem {
        self.label = label
        return self
    }
    
    open func with(tint: UIColor?) -> TextNavigationBarItem {
        self.tint = tint
        return self
    }
    
    open func with(font: UIFont?) -> TextNavigationBarItem {
        self.font = font
        return self
    }
    
    open var label: String?
    
    open var tint: UIColor?
    
    open var font: UIFont?
    
    open override var button: UIBarButtonItem? {
        let button = UIBarButtonItem(title: label, style: .plain, target: target, action: selector)
        let color = tint ?? UIColor.white
        let desiredFont = font ?? EthosTextConfig.shared.regularFont.withSize(14)
        
        var attr = [NSAttributedString.Key : Any]()
        attr.set(NSAttributedString.Key.font, desiredFont, allowNil: false)
        attr.set(NSAttributedString.Key.foregroundColor, color, allowNil: false)
        
        button.setTitleTextAttributes(attr, for: UIControl.State())
        return button
    }
    
}
