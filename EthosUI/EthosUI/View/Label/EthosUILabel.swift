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

open class EthosUILabel: BaseUIView {
    
    // MARK: Constants & Types
    public typealias Delegate = EthosUILabelDelegate
    
    // MARK: - Singleton & Delegate
    public weak var delegate: Delegate?
    
    // MARK: - UI Components
    private let labelView = UILabel(frame: CGRect.zero)
    
    public var labelDescriptor: LabelDescriptor? {
        didSet {
            self.labelView.attributedText = self.labelDescriptor?.attr
            self.labelView.numberOfLines = self.labelDescriptor?.numberOfLines ?? 0
        }
    }
    
    fileprivate var linkCooldown: Delayed<Bool>?
    
    fileprivate var canRespondToLink = true
    
    override open func initialize() {
        self.linkCooldown = Delayed<Bool>(delay: 0.3).with() { [weak self] in self?.canRespondToLink = $0 ?? true }
    }
    
    @discardableResult
    override open func createLayout() -> LifeCycleInterface {
        super.createLayout()
        self.addSubview(labelView)
        labelView.numberOfLines = 0
        return self
    }
    
    override open func frameUpdate() {
        super.frameUpdate()
        self.labelView.frame = self.bounds.insetBy(padding: padding)
    }
    
    // MARK: - Size
    override open func sizeToFit() {
        let size = self.labelView.sizeThatFits(CGSize.maxSize)
        self.frame.size = size.addPadding(padding: padding)
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        let sizeWithoutPadding = size.removePadding(padding: padding)
        let retSize = labelView.sizeThatFits(sizeWithoutPadding)
        return retSize.addPadding(padding: padding)
    }
    
    func handleLink(url: String) {
        guard self.canRespondToLink else { return }
        
        self.canRespondToLink = false
        self.linkCooldown?.set(value: true)
        let didIntercept = self.delegate?.interceptUrl?(url) ?? false
        if !didIntercept {
            EventHelper.APP_OPEN_URL.emit(userInfo: ["url": url])
        }
    }
    
    func didTapOnLink(_ point: CGPoint?) -> String? {
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
    
    
}
