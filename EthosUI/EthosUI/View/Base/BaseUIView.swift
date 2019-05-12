//
//  LifeCycleUIView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class BaseUIView: UIView, LifeCycleInterface, ReusableComponentInterface, FirstResponderInterface {
    
    // MARK: - Constants & Types
    public static let DEFAULT_BORDER_VISIBILITY = false
    
    public static let DEFAULT_BORDER_COLOR = EthosUIConfig.shared.borderColor
    
    open class Config {
        public init() {}
    }
    
    // MARK: - Class Methods
    fileprivate class func createDefaultBorderLayer() -> CALayer {
        let layer = CALayer()
        layer.isHidden = !BaseUIView.DEFAULT_BORDER_VISIBILITY
        layer.backgroundColor = BaseUIView.DEFAULT_BORDER_COLOR.cgColor
        return layer
    }
    
    fileprivate class func createDefaultBorders() -> Rect<CALayer> {
        return Rect<CALayer>(createDefaultBorderLayer(), createDefaultBorderLayer(),
                             createDefaultBorderLayer(), createDefaultBorderLayer())
    }
    
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
    
    public func with(config: Config) -> BaseUIView {
        self.config = config
        return self
    }
    
    // MARK: - Config
    public var shouldRespondToTouch = false
    
    public var config: Config?
    
    // MARK: - UI Components
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
    
    fileprivate var tapCooldown: Delayed<Int>?
    
    fileprivate var recentTaps = 0
    
    fileprivate var size = CGSize.zero
    
    public var padding = Rect<CGFloat>(def: 0)
    
    public var borders = createDefaultBorders()
    
    // MARK: - State variables
    public var borderPadding: Rect<Rect<CGFloat>> {
        return Rect<Rect<CGFloat>>(def: Rect<CGFloat>(def: 0))
    }
    
    public var borderVisible: Rect<Bool> {
        get { return self.borders.map() { !$0.isHidden } }
        set { zip(self.borders, newValue).forEach { $0.0.isHidden = !$0.1 } }
    }
    
    public var borderColors: Rect<CGColor?> {
        get { return self.borders.map() { $0.backgroundColor } }
        set { zip(self.borders, newValue).forEach { $0.0.backgroundColor = $0.1 } }
    }
    
    // MARK: - Borders
    public func resetBorders(needsDisplay: Bool = true) {
        let defaultBorders = BaseUIView.createDefaultBorders()
        self.borderVisible = defaultBorders.map { !$0.isHidden }
        self.borderColors = defaultBorders.map { $0.backgroundColor }
        
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Touch
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        self.recentTaps += 1
        self.tapCooldown?.set(value: 0)
        
        if !shouldRespondToTouch(point, with: event) && view == self {
            return nil
        }
        
        return view
    }
    
    open func shouldRespondToTouch(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return self.recentTaps <= 2 && shouldRespondToTouch
    }
    
    // MARK: - LifeCycleInterface Methods
    open func initialize() {
        self.tapCooldown = Delayed<Int>(delay: 0.3).with() { [weak self] in self?.recentTaps = $0 ?? 0 }
    }
    
    @discardableResult
    open func createLayout() -> LifeCycleInterface {
        self.borders = BaseUIView.createDefaultBorders()
        self.borders.forEach() { self.layer.addSublayer($0) }
        self.resetBorders(needsDisplay: false)
        return self
    }
    
    open func frameUpdate() {
        let horizontalBorderSize = CGSize(width: self.frame.width, height: UIHelper.onePixel)
        let verticalBorderSize = CGSize(width: UIHelper.onePixel, height: self.frame.height)
        
        borders.left.frame = CGRect(origin: CGPoint.zero,
                                    size: verticalBorderSize).insetBy(padding: borderPadding.left)
        borders.top.frame = CGRect(origin: CGPoint.zero,
                                   size: horizontalBorderSize).insetBy(padding: borderPadding.top)
        borders.right.frame = CGRect(origin: CGPoint(x: self.frame.width - UIHelper.onePixel, y: 0),
                                     size: verticalBorderSize).insetBy(padding: borderPadding.right)
        borders.bottom.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height - UIHelper.onePixel),
                                      size: horizontalBorderSize).insetBy(padding: borderPadding.bottom)
    }
    
    open func cleanUp() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.cleanUp() }
    }
    
    open func destroy() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - ReusableComponentInterface Methods
    open func prepareForReuse() {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.prepareForReuse?() }
    }
    
    open func willAppear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.willAppear?(first: first) }
    }
    
    open func onScreen(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.onScreen?(first: first) }
    }
    
    open func didAppear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.didAppear?(first: first) }
    }
    
    open func willDisappear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.willDisappear?(first: first) }
    }
    
    open func offScreen(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.offScreen?(first: first) }
    }
    
    open func didDisappear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.didDisappear?(first: first) }
    }
    
    // MARK: - First Responder & FirstResponderInterface Methods
    open func allowFirstResponderResign() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.allowFirstResponderResign() }
    }
    
    open func preventFirstResponderResign() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.preventFirstResponderResign() }
    }
    
    open override var canBecomeFirstResponder: Bool {
        return self.subviews.reduce(false) { $0 || $1.canBecomeFirstResponder }
    }
    
    open override var canResignFirstResponder: Bool {
        return self.getFirstResponder()?.canResignFirstResponder ?? false
    }
    
    open override var isFirstResponder: Bool {
        return self.getFirstResponder() != nil
    }
    
    open func getFirstResponder() -> UIView? {
        return self.subviews.first() { $0.isFirstResponder }
    }
    
    open override func resignFirstResponder() -> Bool {
        return self.getFirstResponder()?.resignFirstResponder() ?? false
    }
    
}
