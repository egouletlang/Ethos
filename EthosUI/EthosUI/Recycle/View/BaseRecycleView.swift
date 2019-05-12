//
//  BaseRecycleView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/5/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

open class BaseRecycleView: BaseUIView {

    public typealias Delegate = BaseRecycleViewDelegate

    // MARK: - UI Components
    public var contentView = BaseUIView(frame: CGRect.zero)

    // MARK: - State Variables
    fileprivate var availableSize: CGSize {
        guard let m = model else { return self.frame.size }
        return self.frame.insetBy(padding: m.padding).size
    }

    fileprivate var offset: CGPoint {
        guard let m = model else { return CGPoint.zero }
        return self.frame.insetBy(padding: m.padding).origin
    }

    // MARK: - Lifecycle
    @discardableResult
    override open func createLayout() -> LifeCycleInterface {
        super.createLayout()
        
        self.backgroundColor = UIColor.clear
        
        self.addSubview(contentView)
        contentView.createLayout()
        contentView.clipsToBounds = true
        contentView.shouldRespondToTouch = true

        createGestures()
        return self
    }

    override open func frameUpdate() {
        super.frameUpdate()
        self.contentView.frame = CGRect(origin: self.offset, size: self.availableSize)
    }

    override public var borderPadding: Rect<Rect<CGFloat>> {
        guard let m = self.model else { return super.borderPadding }
        return Rect<Rect<CGFloat>>(m.borders.left.padding, m.borders.top.padding, m.borders.right.padding, m.borders.bottom.padding)
    }

    // MARK: - Model
    public weak var model: BaseRecycleModel?

    open func setData(model: BaseRecycleModel) {
        self.model = model

        self.backgroundColor = model.backgroundColor
        self.contentView.layer.backgroundColor = model.contentColor?.cgColor

        self.layer.shadowOffset = model.shadowOffset
        self.layer.shadowRadius = model.shadowRadius
        self.layer.shadowOpacity = model.shadowOpacity

        self.layer.cornerRadius = model.cornerRadius
        self.contentView.layer.cornerRadius = model.cornerRadius

        borders.left.isHidden = !model.borders.left.show
        borders.top.isHidden = !model.borders.top.show
        borders.right.isHidden = !model.borders.right.show
        borders.bottom.isHidden = !model.borders.bottom.show

        borders.forEach() { $0.backgroundColor = model.borderColor.cgColor }
    }

    // MARK: - Delegate
    public weak var delegate: BaseRecycleView.Delegate? {
        didSet {
            self.delegateDidSet()
        }
    }
    
    public weak var labelDelegate: EthosUILabel.Delegate? {
        didSet {
            self.labelDelegateDidSet()
        }
    }

    public func delegateDidSet() {}

    public func labelDelegateDidSet() {}

    // MARK: - Gestures
    open var handleGesturesAutomatically: Bool {
        return true
    }
    
    open var addTap: Bool {
        return true
    }

    open var addLongPress: Bool {
        return true
    }
    
    fileprivate func createGestures() {
        guard handleGesturesAutomatically else { return }
        
        if addTap {
            self.addTap(self, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        }
        
        if addLongPress {
            self.addLongPress(self, selector: #selector(BaseRecycleView.selector_containerLongPressed))
        }
    }
    
    @objc
    open func selector_containerTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.active(view: self)
        if let m = self.model, m.clickResponse != nil {
            self.delegate?.tapped(model: m, view: self)
        }
    }

    @objc
    open func selector_containerLongPressed() {
        self.delegate?.active(view: self)
        if let m = self.model, m.longClickResponse != nil {
            self.delegate?.longPressed(model: m, view: self)
        }
    }

    // MARK: - Size
    open func sizeThatFits(model: BaseRecycleModel, forWidth w: CGFloat) -> CGSize {
        return CGSize(width: w, height: model.getContainerHeight())
    }

}

