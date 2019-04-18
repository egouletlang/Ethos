//
//  MediaDescriptor.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/18/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class MediaDescriptor {
    
    public enum Source: String {
        case Asset = "Asset"
        case Album = "Album"
        case Http = "http://"
        case Https = "https://"
        
        public static var array: [Source] {
            return [.Asset, .Album, .Http, .Https]
        }
    }

    public init(resource: String) {
        self.resource = resource
        if resource.startsWith(Source.Https.rawValue) {
            source = .Https
        } else if resource.startsWith(Source.Http.rawValue) {
            source = .Http
        } else {
            source = .Asset
        }
    }
    
    @discardableResult open func with(transforms: [BaseImageTransform]?) -> MediaDescriptor {
        self.transforms = transforms
        return self
    }
    
    @discardableResult open func add(transform: BaseImageTransform) -> MediaDescriptor {
        if transforms == nil {
            transforms = []
        }
        transforms?.append(transform)
        return self
    }
    
    open var resource: String
    
    open var source: Source
    
    open var transforms: [BaseImageTransform]?
    
    open var hasTransfroms: Bool {
        return (self.transforms?.count ?? 0) > 0
    }
    
    open var key: String {
        return resource
    }
    
    open var transformedKey: String {
        var ret = self.key
        self.transforms?.forEach() { ret = $0.modifyKey(key: ret) }
        return ret
    }
    
    open func transform(image: UIImage?) -> UIImage? {
        var ret = image
        self.transforms?.forEach() { ret = $0.transform(img: ret) }
        return ret
    }
}
