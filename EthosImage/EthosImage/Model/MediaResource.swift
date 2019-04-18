//
//  MediaResource.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosNetwork

open class MediaResource: NSObject, NSCoding {
    
    // MARK: - Constants -
    fileprivate enum Archive: String {
        case data = "data"
        case headers = "headers"
    }
    
    public init(response: EthosHttpResponse) {
        self.headers = response.headers
        self.data = response.data
    }
    
    private var headers: [String: Any]?
    
    open var data: Data?
    
    open var age: Int? {
        return self.getHeader("Age")
    }
    
    open var cacheControl: Int? {
        return data?.count ?? self.getHeader("Cache-Control")
    }
    
    open var contentLength: Int? {
        return data?.count ?? self.getHeader("Content-Length")
    }
    
    open var contentType: String? {
        return self.getHeader("Content-Type")
    }
    
    open var etag: String? {
        return self.getHeader("Etag")
    }
    
    open var expires: String? {
        return self.getHeader("Expires")
    }
    
    open var lastModified: String? {
        return self.getHeader("Last-Modified")
    }
    
    private func getHeader<T>(_ key: String) -> T? {
        return self.headers?.get(key) as? T ??
               self.headers?.get(key.lowercased()) as? T
    }
    
    open var image: UIImage? {
        return self.data?.image
    }
    
    open func getCost() -> Int {
        return self.contentLength ?? (1024 * 1024)
    }
    
    // MARK: - NSCoding Delegate Methods
    public required init(coder aDecoder: NSCoder) {
        data = aDecoder.decodeObject(forKey: Archive.data.rawValue) as? Data
        headers = aDecoder.decodeObject(forKey: Archive.headers.rawValue) as? [String: Any]
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(data, forKey: Archive.data.rawValue)
        aCoder.encode(headers, forKey: Archive.headers.rawValue)
    }
}


