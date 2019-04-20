//
//  LifeCycleUIView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class BaseUIView: UIView, LifeCycleInterface, ReusableViewInterface {
    
    // MARK: Constants & Types
    public typealias Delegate = BaseUIViewDelegate
    
    open class Config {
        public init() {}
    }
    
    // MARK: - Builders & Constructors
    deinit {
        (self as LifeCycleInterface).destroy?()
    }
    
    // MARK: - Singleton & Delegate
    open func with(config: Config) -> BaseUIView {
        self.config = config
        return self
    }
    
    // MARK: - State variables
    open weak var delegate: Delegate? {
        didSet {
            self.subviews.forEach() { ($0 as? BaseUIView)?.delegate = self.delegate }
        }
    }
    
    open var shouldRespondToTouch = true
    
    open var config: Config?
    
    fileprivate var size = CGSize.zero
    
    override open var frame: CGRect {
        didSet {
            self.handleFrameChange()
        }
    }
    
    // MARK: - Parent Methods
    override open func setNeedsDisplay() {
        ThreadHelper.checkMain {
            super.setNeedsDisplay()
        }
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if !shouldRespondToTouch(point, with: event) && view == self {
            return nil
        }
        
        return view
    }
    
    // MARK: - Private Helper Methods
    open func shouldRespondToTouch(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return shouldRespondToTouch
    }
    
    fileprivate func handleFrameChange() {
        if self.size.width != self.frame.size.width {
            (self as LifeCycleInterface).frameWidthUpdate?()
        }
        
        if self.size.height != self.frame.size.height {
            (self as LifeCycleInterface).frameHeightUpdate?()
        }
        
        if self.size != self.frame.size {
            self.size = self.frame.size
            self.frameUpdate()
        }
    }
    
    // MARK: - LifeCycleInterface Methods
    public func createLayout() {}
    
    public func frameUpdate() {}
    
    // MARK: - ReusableViewInterface Methods
    public func prepareForReuse() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.prepareForReuse() }
    }
    
    public func onScreen() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.onScreen() }
    }
    
    public func offScreen() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.offScreen() }
    }
    
    public func cleanUp() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.cleanUp() }
    }
    
}

