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
    
    // MARK: - State variables
    var state = ComponentState()
    
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
    
    // MARK: - Delegate
    open weak var delegate: Delegate? {
        didSet {
            self.subviews.forEach() { ($0 as? BaseUIView)?.delegate = self.delegate }
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
    
    public func cleanUp() {
        self.subviews.forEach() { ($0 as? BaseUIView)?.cleanUp() }
    }
    
    public func destroy() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Size
public extension BaseUIView {
    fileprivate static let SIZE_HANDLE = VariableHandle<CGSize>("size", CGSize.zero)
    
    fileprivate var sizeHandle: VariableHandle<CGSize> {
        return self.state.getHandle(handle: BaseUIView.SIZE_HANDLE)
    }
    
    fileprivate var size: CGSize {
        get { return self.sizeHandle.val }
        set { self.sizeHandle.val = newValue }
    }
}

// MARK: - Borders & Padding
extension BaseUIView {
    
    // MARK: Constants & Types
    fileprivate static let BORDERS_HANDLE = VariableHandle<Rect<CALayer>>("borders", createDefaultBorderRect())
    
    fileprivate static let PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("padding", Rect<CGFloat>(def: 0))
    
    fileprivate var bordersHandle: VariableHandle<Rect<CALayer>> {
        return self.state.getHandle(handle: BaseUIView.BORDERS_HANDLE)
    }
    
    fileprivate var paddingHandle: VariableHandle<Rect<CGFloat>> {
        return self.state.getHandle(handle: BaseUIView.PADDING_HANDLE)
    }
    
    // MARK: - Static & Class Methods
    fileprivate static func createDefaultBorderLayer() -> CALayer {
        let layer = CALayer()
        layer.isHidden = true
        layer.backgroundColor = EthosUIConfig.shared.borderColor.cgColor
        return layer
    }
    
    fileprivate static func createDefaultBorderRect() -> Rect<CALayer> {
        return Rect<CALayer>(createDefaultBorderLayer(), createDefaultBorderLayer(),
                             createDefaultBorderLayer(), createDefaultBorderLayer())
    }
    
    // MARK: - UI Components
    open var borders: Rect<CALayer> {
        get { return self.bordersHandle.val }
        set { self.bordersHandle.val = newValue }
    }
    
    open var borderVisible: Rect<Bool> {
        get { return self.borders.map() { !$0.isHidden } }
        set { zip(self.borders, newValue).forEach { $0.0.isHidden = !$0.1 } }
    }
    
    open var borderColors: Rect<CGColor?> {
        get { return self.borders.map() { $0.backgroundColor } }
        set { zip(self.borders, newValue).forEach { $0.0.backgroundColor = $0.1 } }
    }
    
    open var padding: Rect<CGFloat> {
        get { return self.paddingHandle.val }
        set { self.paddingHandle.val = newValue }
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
        self.borders = Rect<CALayer>(BaseUIView.createDefaultBorderLayer(), BaseUIView.createDefaultBorderLayer(),
                                     BaseUIView.createDefaultBorderLayer(), BaseUIView.createDefaultBorderLayer())
    }
    
    fileprivate func setBorderFrame() {
        borders.left.frame = CGRect(origin: borderOrigins.left, size: verticalBorderSize)
        borders.top.frame = CGRect(origin: borderOrigins.top, size: horizontalBorderSize)
        borders.right.frame = CGRect(origin: borderOrigins.right, size: verticalBorderSize)
        borders.bottom.frame = CGRect(origin: borderOrigins.bottom, size: horizontalBorderSize)
    }
    
    public func resetBorders(needsDisplay: Bool = true) {
        self.borderVisible = BaseUIView.BORDERS_HANDLE.def.map { !$0.isHidden }
        self.borderColors = BaseUIView.BORDERS_HANDLE.def.map { $0.backgroundColor }
        
        if needsDisplay {
            self.setNeedsDisplay()
        }
    }
    
}

// MARK: - ReusableComponentInterface
extension BaseUIView: ReusableComponentInterface {
    
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
    class Config {
        public init() {}
    }
    
    fileprivate static let CONFIG_HANDLE = VariableHandle<Config?>("config", nil)
    
    fileprivate var configHandle: VariableHandle<Config?> {
        return self.state.getHandle(handle: BaseUIView.CONFIG_HANDLE)
    }
    
    var config: Config? {
        get { return self.configHandle.val }
        set { self.configHandle.val = newValue }
    }
    
    // MARK: - Builders & Constructors
    func with(config: Config) -> BaseUIView {
        self.config = config
        return self
    }
}

// MARK: - Touch
public extension BaseUIView {
    
    // MARK: Constants & Types
    fileprivate static let SHOULD_RESPOND_TO_TOUCH_HANDLE = VariableHandle<Bool>("respond_to_touch", false)
    
    fileprivate var shouldRespondToTouchHandle: VariableHandle<Bool> {
        return self.state.getHandle(handle: BaseUIView.SHOULD_RESPOND_TO_TOUCH_HANDLE)
    }
    
    // MARK: - State variables
    var shouldRespondToTouch: Bool {
        get { return self.shouldRespondToTouchHandle.val }
        set { self.shouldRespondToTouchHandle.val = newValue }
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
