//
//  GetUriResource.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import EthosUtil
import EthosNetwork

class GetUriResource: UniqueOperation {
    
    // MARK: - Builders & Constructors
    convenience init(url: String) {
        self.init()
        self.url = url
    }
    
    func with(mediaResource: MediaResource?) -> GetUriResource {
        self.mediaResource = mediaResource
        return self
    }
    
    // MARK: - State variables
    private var url: String?
    
    private var mediaResource: MediaResource?
    
    // MARK: - Parent Methods
    override func getUniqueId() -> String? {
        return self.url
    }
    
    override func run() {
        guard let url = self.url, !url.isEmpty else {
            complete(result: nil); return
        }
        handle(url: url)
    }
    
    // MARK: - Helper Methods
    private func complete(mediaResource: MediaResource?) {
        self.deactivate(result: mediaResource)
    }
    
    private func handle(url: String) {
        // Select a handler
        let resource = defaultHandler(url: url)
        complete(mediaResource: resource)
    }
    
    private func defaultHandler(url: String) -> MediaResource? {
        guard let resource = NetworkHelper.shared.media(url: url, curr: self.mediaResource) else {
            return nil // Could not get the resource
        }
        
        if resource.isEqual(self.mediaResource) {
            return self.mediaResource // resource has not changed
        }
        
        return resource // resource has changed, update
    }
}

