//
//  LifeCycleUIView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

public class BaseUIView: UIView, LifeCycleInterface, ReusableComponentInterface, FirstResponderInterface {
    
    public static let DEFAULT_BORDER_VISIBILITY = false
    
    public static let DEFAULT_BORDER_COLOR = EthosUIConfig.shared.borderColor
    
    public class Config {
        public init() {}
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
    
    // MARK: - UI
    override public var frame: CGRect {
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
    
    // MARK: - State variables
    fileprivate var size = CGSize.zero
    
    public var padding = Rect<CGFloat>(def: 0)
    
    // MARK: - Config
    public var config: Config?
    
    public func with(config: Config) -> BaseUIView {
        self.config = config
        return self
    }
    
    // MARK: - Touch
    public var shouldRespondToTouch: Bool {
        return false
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
        if !shouldRespondToTouch(point, with: event) && view == self {
            return nil
        }
        
        return view
    }
    
    public func shouldRespondToTouch(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return shouldRespondToTouch
    }
    
    // MARK: - Borders
    public var borders = createDefaultBorders()
    
    public var borderPadding = Rect<Rect<CGFloat>>(def: Rect<CGFloat>(def: 0))
    
    public var borderVisible: Rect<Bool> {
        get { return self.borders.map() { !$0.isHidden } }
        set { zip(self.borders, newValue).forEach { $0.0.isHidden = !$0.1 } }
    }
    
    public var borderColors: Rect<CGColor?> {
        get { return self.borders.map() { $0.backgroundColor } }
        set { zip(self.borders, newValue).forEach { $0.0.backgroundColor = $0.1 } }
    }
    
    fileprivate var horizontalBorderSize: CGSize {
        return CGSize(width: self.frame.width, height: UIHelper.onePixel)
    }
    
    fileprivate var verticalBorderSize: CGSize {
        return CGSize(width: UIHelper.onePixel, height: self.frame.height)
    }
    
    fileprivate var borderOrigins: Rect<CGPoint> {
        return Rect<CGPoint>(CGPoint.zero, CGPoint.zero,
                             CGPoint(x: self.frame.width - UIHelper.onePixel, y: 0),
                             CGPoint(x: 0, y: self.frame.height - UIHelper.onePixel))
    }
    
    fileprivate func setBorderFrame() {
        borders.left.frame = CGRect(origin: borderOrigins.left, size: verticalBorderSize).insetBy(padding: borderPadding.left)
        borders.top.frame = CGRect(origin: borderOrigins.top, size: horizontalBorderSize).insetBy(padding: borderPadding.top)
        borders.right.frame = CGRect(origin: borderOrigins.right, size: verticalBorderSize).insetBy(padding: borderPadding.right)
        borders.bottom.frame = CGRect(origin: borderOrigins.bottom, size: horizontalBorderSize).insetBy(padding: borderPadding.bottom)
    }
    
    fileprivate static func createDefaultBorderLayer() -> CALayer {
        let layer = CALayer()
        layer.isHidden = BaseUIView.DEFAULT_BORDER_VISIBILITY
        layer.backgroundColor = BaseUIView.DEFAULT_BORDER_COLOR.cgColor
        return layer
    }
    
    fileprivate static func createDefaultBorders() -> Rect<CALayer> {
        return Rect<CALayer>(createDefaultBorderLayer(), createDefaultBorderLayer(),
                             createDefaultBorderLayer(), createDefaultBorderLayer())
    }
    
    public func resetBorders(needsDisplay: Bool = true) {
        let defaultBorders = BaseUIView.createDefaultBorders()
        self.borderVisible = defaultBorders.map { !$0.isHidden }
        self.borderColors = defaultBorders.map { $0.backgroundColor }
        
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - LifeCycleInterface Methods
    public func createLayout() {
        self.borders = Rect<CALayer>(BaseUIView.createDefaultBorderLayer(), BaseUIView.createDefaultBorderLayer(),
                                     BaseUIView.createDefaultBorderLayer(), BaseUIView.createDefaultBorderLayer())
        self.resetBorders(needsDisplay: false)
    }
    
    public func frameUpdate() {
        self.setBorderFrame()
    }
    
    public func cleanUp() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.cleanUp() }
    }
    
    public func destroy() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - ReusableComponentInterface
    public func prepareForReuse() {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.prepareForReuse?() }
    }
    
    public func willAppear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.willAppear?(first: first) }
    }
    
    public func onScreen(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.onScreen?(first: first) }
    }
    
    public func didAppear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.didAppear?(first: first) }
    }
    
    public func willDisappear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.willDisappear?(first: first) }
    }
    
    public func offScreen(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.offScreen?(first: first) }
    }
    
    public func didDisappear(first: Bool) {
        self.subviews.forEach() { ($0 as? ReusableComponentInterface)?.didDisappear?(first: first) }
    }
    
    // MARK: - First Responder & FirstResponderInterface
    public func allowFirstResponderResign() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.allowFirstResponderResign() }
    }
    
    public func preventFirstResponderResign() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.preventFirstResponderResign() }
    }
    
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
