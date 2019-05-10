//
//  BaseUIView_Gesture.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/9/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

extension BaseUIView: UIGestureRecognizerDelegate {
    
    fileprivate class BaseLongPressGestureRecognizer: UILongPressGestureRecognizer {
        var selector: Selector?
    }
    
    public func addTap(_ view: UIView, selector: Selector, count: Int = 1) {
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        tapGesture.numberOfTapsRequired = count
        tapGesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    public func addLongPress(_ view: UIView, selector: Selector, duration: TimeInterval = 0.5) {
        let localSelector = #selector(BaseUIView.selector_longPressDetected(_:))
        let longPressGesture = BaseLongPressGestureRecognizer(target: self, action: localSelector)
        longPressGesture.minimumPressDuration = duration
        longPressGesture.selector = selector
        longPressGesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(longPressGesture)
    }
    
    @objc func selector_longPressDetected(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            if let selector = (sender as? BaseLongPressGestureRecognizer)?.selector {
                performSelector(onMainThread: selector, with: self, waitUntilDone: false)
            }
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate Methods
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith
                                  otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer as? UITapGestureRecognizer == nil)
    }
    
}
