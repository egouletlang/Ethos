//
//  LifeCycleUIView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

public class BaseUIView: UIView, LifeCycleInterface {
    
    // MARK: Constants & Types
    public typealias Delegate = BaseUIViewDelegate
    
    // MARK: - Builders & Constructors
    public override init(frame: CGRect) {
        super.init(frame: frame)
        (self as LifeCycleInterface).initialize?()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        (self as LifeCycleInterface).destroy?()
    }
    
    // MARK: - UI Components
    open var padding = Rect<CGFloat>(def: 0)
    
    // MARK: - State variables
    open weak var delegate: Delegate? {
        didSet {
            self.subviews.forEach() { ($0 as? BaseUIView)?.delegate = self.delegate }
        }
    }
    
    var state = [String: Any]()
    
    fileprivate var size = CGSize.zero
    
    override open var frame: CGRect {
        didSet {
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
    }
    
    override open func setNeedsDisplay() {
        ThreadHelper.checkMain {
            super.setNeedsDisplay()
        }
    }
    
    // MARK: - LifeCycleInterface Methods
    public func createLayout() {
        self.createBorders()
        self.resetBorders(needsDisplay: false)
    }
    
    public func frameUpdate() {
        self.setBorderFrame()
    }
    
}

// MARK: - Borders
extension BaseUIView {
    
    // MARK: Constants & Types
    fileprivate static let DEFAULT_BORDER_VISIBLE = false
    
    fileprivate static let STATE_KEY_BORDERS = "borders"
    
    fileprivate static let STATE_KEY_BORDER_VISIBLE = "border_visible"
    
    // MARK: - UI Components
    open var borders: Rect<CALayer>? {
        get {
            return self.state.get(BaseUIView.STATE_KEY_BORDERS) as? Rect<CALayer>
        }
        set {
            self.state.set(BaseUIView.STATE_KEY_BORDERS, newValue)
        }
    }
    
    open var borderVisible: Rect<Bool> {
        get {
            guard let visible = self.state.get(BaseUIView.STATE_KEY_BORDER_VISIBLE) as? Rect<Bool> else {
                return Rect<Bool>(def: BaseUIView.DEFAULT_BORDER_VISIBLE)
            }
            return visible
        }
        set {
            self.state.set(BaseUIView.STATE_KEY_BORDER_VISIBLE, newValue)
        }
    }
    
    // MARK: - State variables
    private var horizontalBorderSize: CGSize {
        return CGSize(width: self.frame.width, height: UIHelper.onePixel)
    }
    
    private var verticalBorderSize: CGSize {
        return CGSize(width: UIHelper.onePixel, height: self.frame.height)
    }
    
    private var borderOrigins: Rect<CGPoint> {
        return Rect<CGPoint>(CGPoint.zero, CGPoint.zero,
                             CGPoint(x: self.frame.width - UIHelper.onePixel, y: 0),
                             CGPoint(x: 0, y: self.frame.height - UIHelper.onePixel))
    }
    
    // MARK: - Helper Methods
    fileprivate func createBorders() {
        self.borders = Rect<CALayer>(CALayer(), CALayer(), CALayer(), CALayer())
    }
    
    fileprivate func setBorderFrame() {
        borders?.left.frame = CGRect(origin: borderOrigins.left, size: verticalBorderSize)
        borders?.top.frame = CGRect(origin: borderOrigins.top, size: horizontalBorderSize)
        borders?.right.frame = CGRect(origin: borderOrigins.right, size: verticalBorderSize)
        borders?.bottom.frame = CGRect(origin: borderOrigins.bottom, size: horizontalBorderSize)
    }
    
    // MARK: - Interface
    public func setBorderVisibility(_ visibility: Bool, needsDisplay: Bool = true) {
        self.setBorderVisibility(Rect<Bool>(def: visibility), needsDisplay: needsDisplay)
    }
    
    public func setBorderVisibility(_ rect: Rect<Bool>, needsDisplay: Bool = true) {
        self.borderVisible = rect
        
        borders?.left.isHidden = !self.borderVisible.left
        borders?.top.isHidden = !self.borderVisible.top
        borders?.right.isHidden = !self.borderVisible.right
        borders?.bottom.isHidden = !self.borderVisible.bottom
        
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    public func setBorderColor(_ color: UIColor, needsDisplay: Bool = true) {
        borders?.makeIterator().forEach() { $0.backgroundColor = color.cgColor }
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    public func resetBorders(needsDisplay: Bool = true) {
        self.setBorderVisibility(BaseUIView.DEFAULT_BORDER_VISIBLE, needsDisplay: false)
        self.setBorderColor(EthosUIConfig.shared.borderColor, needsDisplay: false)
        
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
}

// MARK: - ReusableComponentInterface
extension BaseUIView: ReusableComponentInterface {
    
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

// MARK: - First Responder & FirstResponderInterface
extension BaseUIView: FirstResponderInterface {
    
    public func allowFirstResponderResign() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.allowFirstResponderResign() }
    }
    
    public func preventFirstResponderResign() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.preventFirstResponderResign() }
    }
    
    // MARK: - First Responder
    public override var canBecomeFirstResponder: Bool {
        return self.subviews.reduce(false) { $0 || $1.canBecomeFirstResponder }
    }
    
    public override var canResignFirstResponder: Bool {
        return self.getFirstResponder()?.canResignFirstResponder ?? false
    }
    
    public override var isFirstResponder: Bool {
        return self.getFirstResponder() != nil
    }
    
    public func getFirstResponder() -> UIView? {
        return self.subviews.first() { $0.isFirstResponder }
    }
    
    public override func resignFirstResponder() -> Bool {
        return self.getFirstResponder()?.resignFirstResponder() ?? false
    }
    
}

// MARK: - Config
public extension BaseUIView {
    
    // MARK: Constants & Types
    fileprivate static let STATE_KEY_CONFIG = "config"
    
    class Config {
        public init() {}
    }
    
    // MARK: - Builders & Constructors
    func with(config: Config) -> BaseUIView {
        self.state.set(BaseUIView.STATE_KEY_CONFIG, config)
        return self
    }
    
    // MARK: - State variables
    var config: Config? {
        return self.state.get(BaseUIView.STATE_KEY_CONFIG) as? Config
    }
    
}

// MARK: - Touch
public extension BaseUIView {
    
    // MARK: Constants & Types
    fileprivate static let DEFAULT_SHOULD_RESPOND_TO_TOUCH = false
    
    fileprivate static let STATE_KEY_RESPOND_TO_TOUCH = "respond_to_touch"
    
    // MARK: - State variables
    var shouldRespondToTouch: Bool {
        return self.state.get(BaseUIView.STATE_KEY_RESPOND_TO_TOUCH) as? Bool ?? BaseUIView.DEFAULT_SHOULD_RESPOND_TO_TOUCH
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if !shouldRespondToTouch(point, with: event) && view == self {
            return nil
        }
        
        return view
    }
    
    @objc
    func shouldRespondToTouch(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return shouldRespondToTouch
    }
}
