//
//  NetworkHelper_EXT.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosNetwork

fileprivate let mediaQueue = DispatchQueue(label: "networking:media", qos: .background, attributes: .concurrent)

extension NetworkHelper {
    
    func media(url: String, curr: MediaResource? = nil, timeout: TimeInterval = 30) -> MediaResource? {
        let request = EthosHttpRequest(url: url).with(method: curr != nil ? .head : .get)
        
        if let etag = curr?.etag {
            request.add(header: "If-None-Match", value: etag)
        }
        
        if let lastModified = curr?.lastModified {
            request.add(header: "If-Modified-Since", value: lastModified)
        }
        
        guard let response = self.syncRequest(request: request, queue: mediaQueue) else {
            return nil
        }
        
        if response.success {
            return MediaResource(response: response)
        } else if response.statusCode == 304 { // The resource has not changed
            return curr
        }
        
        return nil
    }
    
    func data(url: String, timeout: TimeInterval = 30) -> Data? {
        return self.media(url: url, timeout: timeout)?.data
    }
    
    func image(url: String, timeout: TimeInterval = 30) -> UIImage? {
        return self.media(url: url, timeout: timeout)?.image
    }
}
