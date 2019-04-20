//
//  EthosUILabel.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil
import EthosText
import UIKit

open class EthosUILabel: EthosUIView {
    
    // MARK: Constants & Types
    public typealias LabelDelegate = EthosUILabelDelegate
    
    // MARK: - Singleton & Delegate
    open weak var labelDelegate: LabelDelegate?
    
    // MARK: - UI Components
    private let labelView = UILabel(frame: CGRect.zero)
    
    open var labelDescriptor: LabelDescriptor? {
        didSet {
            self.labelView.attributedText = self.labelDescriptor?.attr
        }
    }
    
    open var padding = Rect<CGFloat>(0, 0, 0, 0)
    
    // MARK: - State variables
    fileprivate var canRespondToTap = true
    
    fileprivate var tapCooldown: Delayed<Bool>?
    
    // MARK: - Lifecycle Methods
    public func initialize() {
        self.tapCooldown = Delayed<Bool>(delay: 0.3)
                                .with() { [weak self] in self?.canRespondToTap = $0 ?? true }
    }
    
    public override func createLayout() {
        super.createLayout()
        self.addSubview(labelView)
        labelView.numberOfLines = 0
    }
    
    public override func frameUpdate() {
        super.frameUpdate()
        self.labelView.frame = self.bounds.insetBy(padding: padding)
    }
    
    
    // MARK: - Handling Links -
    open override func shouldRespondToTouch(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return canRespondToTap && !willConsumeLocationTap(point)
    }
    
    open func willConsumeLocationTap(_ point: CGPoint?) -> Bool {
        canRespondToTap = false
        tapCooldown?.set(value: true)
        
        if let url = didTapOnLink(point) {
            let didIntercept = self.labelDelegate?.interceptUrl?(url) ?? false
            if !didIntercept {
                EventHelper.APP_OPEN_URL.emit(userInfo: ["url": url])
            }
            return true
        }
        return false
    }
    
    open func didTapOnLink(_ point: CGPoint?) -> String? {
        guard var location = point, self.labelView.frame.contains(location) else {
            return nil
        }
        
        guard let desc = self.labelDescriptor, let attr = desc.attr, desc.links.count > 0 else {
            return nil
        }
        
        
        let textStorage = NSTextStorage(attributedString: attr)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: self.labelView.frame.size)
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        textContainer.maximumNumberOfLines = self.labelView.numberOfLines
        textContainer.lineBreakMode = self.labelView.lineBreakMode
        textContainer.lineFragmentPadding = 0
        
        location.y -= (self.frame.size.height - layoutManager.height) / 2
        
        let charIndex = layoutManager.characterIndex(for: location, in: textContainer,
                                                     fractionOfDistanceBetweenInsertionPoints: nil)
        
        return desc.links
                   .compactMap() { NSLocationInRange(charIndex, $0.value) ? $0.key : nil }
                   .first
        
    }
    
    override open func sizeToFit() {
        let size = self.labelView.sizeThatFits(CGSize.maxSize)
        self.frame.size = size.addPadding(padding: padding)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeWithoutPadding = size.removePadding(padding: padding)
        let retSize = labelView.sizeThatFits(sizeWithoutPadding)
        return retSize.addPadding(padding: padding)
    }
    
}
