//
//  EthosUIView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class EthosUIView: BaseUIView {
    
    // MARK: Constants & Types
    fileprivate static let DEFAULT_BORDER_VISIBLE = false
    
    open var borders = Rect<CALayer>(def: CALayer())
    
    open var borderVisible = Rect<Bool>(def: EthosUIView.DEFAULT_BORDER_VISIBLE)
    
    public override func createLayout() {
        super.createLayout()
        self.resetBorders(needsDisplay: false)
    }
    
    public override func frameUpdate() {
        super.frameUpdate()
        
        let horizontalSize = CGSize(width: self.frame.width, height: UIHelper.onePixel)
        let verticalSize = CGSize(width: UIHelper.onePixel, height: self.frame.height)
        let rightOrigin = CGPoint(x: self.frame.width - UIHelper.onePixel, y: 0)
        let bottomOrigin = CGPoint(x: 0, y: self.frame.height - UIHelper.onePixel)
        
        borders.left.frame = CGRect(origin: CGPoint.zero, size: verticalSize)
        borders.top.frame = CGRect(origin: CGPoint.zero, size: horizontalSize)
        borders.right.frame = CGRect(origin: rightOrigin, size: verticalSize)
        borders.bottom.frame = CGRect(origin: bottomOrigin, size: horizontalSize)
    }
    
    public func setBorderVisibility(_ visibility: Bool, needsDisplay: Bool = true) {
        borders.makeIterator().forEach() { $0.isHidden = !visibility }
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    public func setBorderVisibility(_ rect: Rect<Bool>, needsDisplay: Bool = true) {
        borders.left.isHidden = !rect.left
        borders.top.isHidden = !rect.top
        borders.right.isHidden = !rect.right
        borders.bottom.isHidden = !rect.bottom
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    public func setBorderColor(_ color: UIColor, needsDisplay: Bool = true) {
        borders.makeIterator().forEach() { $0.backgroundColor = color.cgColor }
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    public func resetBorders(needsDisplay: Bool = true) {
        self.setBorderVisibility(EthosUIView.DEFAULT_BORDER_VISIBLE, needsDisplay: false)
        self.setBorderColor(EthosUIConfig.shared.borderColor, needsDisplay: false)
        
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
}
