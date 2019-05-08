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

public class EthosUIMediaView: BaseUIView {
    
    // MARK: - Constants & Types
    public typealias ImageCallback = (UIImage?) -> Void
    
    // MARK: - UI Components
    private let imageView = UIImageView(frame: CGRect.zero)
    
    // MARK: - UI Variables
    override public var contentMode: UIView.ContentMode {
        get {
            return imageView.contentMode
        }
        set {
            imageView.contentMode = newValue
        }
    }
    
    // MARK: - State variables
    private var activeDescriptor: MediaDescriptor?
    
    public var defaultImage: UIImage?
    
    public var image: UIImage? {
        return self.imageView.image
    }
    
    // MARK: - LifeCycleInterface Methods
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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.clear(setDefault: true)
    }
    
    // MARK: - Private Helper
    private func isActiveResource(descriptor: MediaDescriptor) -> Bool {
        guard let active = self.activeDescriptor else {
            return false
        }
        
        return active.resource != descriptor.resource
    }
    
    // MARK: - MediaResource Handler
    private func handle(mediaResource: MediaResource?) {
        guard Thread.isMainThread else {
            ThreadHelper.main { self.handle(mediaResource: mediaResource) }
            return
        }
        
        guard let res = mediaResource, let image = res.image else {
            self.clear(setDefault: true)
            return
        }
        
        if self.shouldAddFadeEffect(mediaResource: res) {
            self.addFadeEffect(image: image)
        } else {
            self.imageView.image = image
        }
    }
    
    // MARK: - Interface
    open func fetch(descriptor: MediaDescriptor?, callback: ImageCallback?) {
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
                    self.handle(mediaResource: resource)
                }
                callback?(resource?.image)
            }
        }
    }
    
    open func load(resource: String, transforms: [BaseImageTransform]? = nil, callback: ImageCallback? = nil) {
        let descriptor = MediaDescriptor(resource: resource).with(transforms: transforms)
        self.fetch(descriptor: descriptor, callback: callback)
    }
    
    open func clear(setDefault: Bool = true) {
        self.activeDescriptor = nil
        self.imageView.image = self.defaultImage
    }
    
    // MARK: - Fade Effect
    public enum FadeInEffect {
        case none
        case web
        case webFirstTime
    }
    
    public var fadeEffect = FadeInEffect.webFirstTime
    
    fileprivate var descriptorSource: MediaDescriptor.Source {
        return self.activeDescriptor?.source ?? .Asset
    }
    
    // MARK: - Interface
    fileprivate func shouldAddFadeEffect(mediaResource: MediaResource) -> Bool {
        guard fadeEffect != .none else { return false }
        
        let isWebResource = self.descriptorSource == .Http || self.descriptorSource == .Https
        let isWebResponse = mediaResource.source == .web
        
        switch (fadeEffect) {
        case .web:
            return isWebResource
        case .webFirstTime:
            return isWebResource && isWebResponse
        default:
            return false
        }
        
    }
    
    fileprivate func addFadeEffect(image: UIImage) {
        UIView.transition(with: self.imageView, duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.imageView.image = image },
                          completion: nil)
    }
    
    
}
