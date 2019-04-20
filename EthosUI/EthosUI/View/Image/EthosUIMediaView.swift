//
//  EthosUIMediaView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/20/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil
import EthosImage

open class EthosUIMediaView: BaseUIView {
    
    // MARK: - Constants & Types
    
    public typealias ImageCallback = (UIImage?) -> Void
    
    public enum FadeInEffect {
        case none
        case web
        case webFirstTime
    }
    
    // MARK: - UI Components -
    private let imageView = UIImageView(frame: CGRect.zero)
    
    open var padding = Rect<CGFloat>(def: 0)
    
    // MARK: - State variables
    private var activeDescriptor: MediaDescriptor?
    
    open var defaultImage: UIImage?
    
    open var fadeEffect = FadeInEffect.webFirstTime
    
    override open var contentMode: UIView.ContentMode {
        get {
            return imageView.contentMode
        }
        set {
            imageView.contentMode = newValue
        }
    }
    
    open var currentImage: UIImage? {
        return self.imageView.image
    }
    
    open var desiredSize: CGSize {
        return self.currentImage?.size ?? CGSize.zero
    }
    
    
    // MARK: - Parent Methods -
    override open func createLayout() {
        super.createLayout()
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        self.clipsToBounds = true
    }
    
    override open func frameUpdate() {
        super.frameUpdate()
        self.imageView.frame = self.bounds.insetBy(padding: padding)
    }
    
    private func isActiveResource(descriptor: MediaDescriptor) -> Bool {
        guard let active = self.activeDescriptor else {
            return false
        }
        
        return active.resource != descriptor.resource
    }
    
    open func load(descriptor: MediaDescriptor?, callback: ImageCallback?) {
        guard let desc = descriptor else {
            self.clear(setDefault: true)
            callback?(nil)
            return
        }
        
        ThreadHelper.background {
            if self.isActiveResource(descriptor: desc) { return }
            self.activeDescriptor = desc
            
            ImageHelper.shared.get(mediaDescriptor: desc) { (resource) in
                if self.isActiveResource(descriptor: desc) {
                    self.load(descriptor: desc, mediaResource: resource)
                }
                callback?(resource?.image)
            }
        }
    }
    
    // MARK: - Load resources -
    open func load(descriptor: MediaDescriptor, mediaResource: MediaResource?) {
        guard Thread.isMainThread else {
            ThreadHelper.main { self.load(descriptor: descriptor, mediaResource: mediaResource) }
            return
        }
        
        guard let res = mediaResource, let image = res.image else {
            self.clear(setDefault: true)
            return
        }
        
        self.load(image: image, descSource: descriptor.source, resSource: res.source)
    }
    
    open func load(image: UIImage, descSource: MediaDescriptor.Source, resSource: MediaResource.Source) {
        guard Thread.isMainThread else {
            ThreadHelper.main { self.load(image: image, descSource: descSource, resSource: resSource) }
            return
        }
        
        let isWebResource = descSource == .Http || descSource == .Https
        let isWebResponse = resSource == .web
        
        var shouldAnimate = false
        switch (fadeEffect) {
        case .web:
            shouldAnimate = isWebResource
        case .webFirstTime:
            shouldAnimate = isWebResource && isWebResponse
        default:
            break
        }
        
        if (shouldAnimate) {
            UIView.transition(with: self.imageView, duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = image },
                              completion: nil)
        } else {
            self.imageView.image = image
        }
        
    }
    
    open func clear(setDefault: Bool = true) {
        self.activeDescriptor = nil
        self.imageView.image = self.defaultImage
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.clear(setDefault: true)
    }
    
    open func load(resource: String, transforms: [BaseImageTransform]? = nil, callback: ImageCallback? = nil) {
        let descriptor = MediaDescriptor(resource: resource).with(transforms: transforms)
        self.load(descriptor: descriptor, callback: callback)
    }
    
}
