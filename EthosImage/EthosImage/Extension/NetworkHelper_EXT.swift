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
    
    private func getMediaResponse(url: String, timeout: TimeInterval = 30) -> EthosHttpResponse? {
        return self.syncRequest(request: EthosHttpRequest(url: url), queue: mediaQueue)
    }
    
    func media(url: String, timeout: TimeInterval = 30) -> MediaResource? {
        guard let response = self.getMediaResponse(url: url, timeout: timeout) else {
            return nil
        }
        return MediaResource(response: response)
    }
    
    func image(url: String, timeout: TimeInterval = 30) -> Data? {
        return self.media(url: url, timeout: timeout)?.data
    }
    
    func image(url: String, timeout: TimeInterval = 30) -> UIImage? {
        return self.media(url: url, timeout: timeout)?.image
    }
}
