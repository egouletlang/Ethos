//
//  UIRefreshView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class UIRefreshView: UIView {
    
    public typealias RefreshCompletion = () -> Void
    
    public struct Constants {
        
        static let pullTag = 810
        
        static let pushTag = 811
        
        static let alpha = true
        
        static let height: CGFloat = 80
        
        static let imageName: String = "down_arrow.png"
        
        static let animationDuration: Double = 0.2
        
        static let fixedTop = true
    }
    
    public struct Options {
        
        public static let DEFAULT_BACKGROUND_COLOR = UIColor.clear
        
        public static let DEFAULT_INDICATOR_COLOR = UIColor.gray
        
        public static let DEFAULT_AUTO_STOP_TIME = PREVENT_AUTO_STOP
        
        public static let DEFAULT_FIXED_SECTION_HEADER = false
        
        public static let PREVENT_AUTO_STOP: Double = -1
        
        public var backgroundColor: UIColor
        
        public var indicatorColor: UIColor
        
        public var autoStopTime: Double
        
        public var fixedSectionHeader: Bool
        
        public static func buildDefault() -> Options {
            return Options(backgroundColor: DEFAULT_BACKGROUND_COLOR, indicatorColor: DEFAULT_INDICATOR_COLOR,
                           autoStopTime: DEFAULT_AUTO_STOP_TIME, fixedSectionHeader: DEFAULT_FIXED_SECTION_HEADER)
        }
    }
    
    public enum State {
        case pulling
        case triggered
        case refreshing
        case stop
        case finish
    }
    
    // MARK: - Constructors
    public override convenience init(frame: CGRect) {
        self.init(options: Options.buildDefault(), image: nil, frame:frame, refreshCompletion: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(options: Options, image: UIImage?, frame: CGRect, refreshCompletion: RefreshCompletion?, down: Bool = true) {
        self.options = options
        self.refreshCompletion = refreshCompletion
        
        self.backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        self.backgroundView.backgroundColor = self.options.backgroundColor
        self.backgroundView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        
        self.refreshView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        self.refreshView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        self.refreshView.image = image
        
        self.indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        self.indicatorView.bounds = self.refreshView.bounds
        self.indicatorView.autoresizingMask = self.refreshView.autoresizingMask
        self.indicatorView.hidesWhenStopped = true
        self.indicatorView.color = options.indicatorColor
        self.pull = down
        
        super.init(frame: frame)
        self.addSubview(indicatorView)
        self.addSubview(backgroundView)
        self.addSubview(refreshView)
        self.autoresizingMask = .flexibleWidth
    }
    
    deinit {
        self.removeRegister()
    }
    
    // MARK: - UI
    fileprivate var backgroundView: UIView
    
    fileprivate var refreshView: UIImageView
    
    fileprivate var indicatorView: UIActivityIndicatorView
    
    fileprivate var scrollViewInsets: UIEdgeInsets = .zero
    
    // MARK: - State
    fileprivate var options: Options
    
    
    // MARK: Variables
    let contentOffsetKeyPath = "contentOffset"
    let contentSizeKeyPath = "contentSize"
    var kvoContext = "UIRefreshViewKVOContext"
    
    
    fileprivate var refreshCompletion: RefreshCompletion?
    
    fileprivate var pull: Bool = true
    
    fileprivate var positionY: CGFloat = 0 {
        didSet {
            guard self.positionY != oldValue else { return }
            var frame = self.frame
            frame.origin.y = positionY
            self.frame = frame
        }
    }
    
    var state: State = .pulling {
        didSet {
            guard self.state != oldValue else { return }
            
            switch self.state {
            case .stop:
                stopAnimating()
            case .finish:
                var duration = Constants.animationDuration
                var time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.stopAnimating()
                }
                duration = duration * 2
                time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.removeFromSuperview()
                }
            case .refreshing:
                startAnimating()
            case .pulling:
                refreshViewRotation(transform: CGAffineTransform.identity)
            case .triggered:
                refreshViewRotation(transform: CGAffineTransform(rotationAngle: CGFloat(.pi-0.0000001)))
            }
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.refreshView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        self.refreshView.frame = refreshView.frame.offsetBy(dx: 0, dy: 0)
        self.indicatorView.center = self.refreshView.center
    }
    
    override open func willMove(toSuperview superView: UIView!) {
        //superview NOT superView, DO NEED to call the following method
        //superview dealloc will call into this when my own dealloc run later!!
        self.removeRegister()
        guard let scrollView = superView as? UIScrollView else {
            return
        }
        scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &kvoContext)
        if !pull {
            scrollView.addObserver(self, forKeyPath: contentSizeKeyPath, options: .initial, context: &kvoContext)
        }
    }
    
    fileprivate func removeRegister() {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
            if !pull {
                scrollView.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &kvoContext)
            }
        }
    }
    
    
    // MARK: KVO
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView else {
            return
        }
        if keyPath == contentSizeKeyPath {
            self.positionY = scrollView.contentSize.height
            return
        }
        
        //        if !(context == &kvoContext && keyPath == contentOffsetKeyPath) {
        //            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        //            return
        //        }
        
        // Pulling State Check
        let offsetY = scrollView.contentOffset.y
        
        // Alpha set
        if Constants.alpha {
            var alpha = abs(offsetY) / (self.frame.size.height + 40)
            if alpha > 0.8 {
                alpha = 0.8
            }
            self.refreshView.alpha = alpha
        }
        
        if offsetY <= 0 {
            if !self.pull {
                return
            }
            
            if offsetY < -self.frame.size.height {
                // pulling or refreshing
                if scrollView.isDragging == false && self.state != .refreshing { //release the finger
                    self.state = .refreshing //startAnimating
                } else if self.state != .refreshing { //reach the threshold
                    self.state = .triggered
                }
            } else if self.state == .triggered {
                //starting point, start from pulling
                self.state = .pulling
            }
            return //return for pull down
        }
        
        //push up
        let upHeight = offsetY + scrollView.frame.size.height - scrollView.contentSize.height
        if upHeight > 0 {
            // pulling or refreshing
            if self.pull {
                return
            }
            if upHeight > self.frame.size.height {
                // pulling or refreshing
                if scrollView.isDragging == false && self.state != .refreshing { //release the finger
                    self.state = .refreshing //startAnimating
                } else if self.state != .refreshing { //reach the threshold
                    self.state = .triggered
                }
            } else if self.state == .triggered  {
                //starting point, start from pulling
                self.state = .pulling
            }
        }
    }
    
    // MARK: private
    
    fileprivate func startAnimating() {
        self.indicatorView.startAnimating()
        self.refreshView.isHidden = true
        
        guard let scrollView = superview as? UIScrollView else { return }
        scrollViewInsets = scrollView.contentInset
        
        var insets = scrollView.contentInset
        if pull {
            insets.top += self.frame.size.height
        } else {
            insets.bottom += self.frame.size.height
        }
        
        let animations = {
            scrollView.contentInset = insets
        }
        
        
        let completion: (Bool) -> Void = { _ in
            if self.options.autoStopTime != Options.PREVENT_AUTO_STOP {
                let time = DispatchTime.now() + Double(Int64(self.options.autoStopTime * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    self.state = .stop
                }
            }
            self.refreshCompletion?()
        }
        
        UIView.animate(withDuration: Constants.animationDuration,
                       delay: 0,
                       options: [],
                       animations: animations,
                       completion: completion)
    }
    
    fileprivate func stopAnimating() {
        self.indicatorView.stopAnimating()
        self.refreshView.isHidden = false
        guard let scrollView = superview as? UIScrollView else { return }
        
        let animations = {
            scrollView.contentInset = self.scrollViewInsets
            self.refreshView.transform = CGAffineTransform.identity
        }
        
        let completion: (Bool) -> Void = { _ in
            self.state = .pulling
        }
        
        let duration = Constants.animationDuration
        UIView.animate(withDuration: duration, animations: animations, completion: completion)
    }
    
    fileprivate func refreshViewRotation(transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.2, delay: 0, options:[], animations: {
            self.refreshView.transform = transform
        }, completion:nil)
    }
}
