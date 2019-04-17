//
//  EthosApiRequest.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import SwiftyJSON
import EthosUtil

open class EthosApiRequest: EthosHttpRequest {
    
    // MARK: URL -
    open override var url: String {
        var arr = [String]()
        if !host.isEmpty { arr.append(host) }
        if !api.isEmpty { arr.append(api) }
        if !endpoint.isEmpty { arr.append(endpoint) }
        return arr.joined(separator: "/")
    }
    
    open var host: String {
        return ""
    }
    
    open var api: String {
        return ""
    }
    
    open var endpoint: String {
        return ""
    }
    
    // MARK: Headers -
    open override var headers: [String : String]? {
        var headers = [String: String]()
        headers.set("Content-Type", self.contentType.rawValue)
        customHeaders.forEach { headers.set($0, $1, allowNil: false) }
        return headers
    }
    
    open var contentType: ContentType {
        return .json
    }
    
    open var customHeaders: [String : String] {
        return [:]
    }
    
    
    // MARK: - Handlers
    open func withHandler(handler: @escaping (EthosHttpResponse) -> Void) -> EthosApiRequest {
        self.handler = handler
        return self
    }
    
    open var handler: ((EthosHttpResponse) -> Void)?
    
    open func onSuccess(response: EthosHttpResponse) {}
    
    open func onConnectivityError(response: EthosHttpResponse) {}
    
    open func onUnauthorized(response: EthosHttpResponse) {}
    
    open func onServerError(response: EthosHttpResponse) {}

    
    // MARK: - Retry
    fileprivate var authRetryCount = 0
    
    fileprivate var connectivityRetryCount = 0
    
    open var authRetryLimit: Int {
        return 1
    }
    
    open var connectivityRetryLimit: Int {
        return 30
    }
    
    open func reestablishAuth(authEstablised: @escaping (Bool) -> Void) {}

    // MARK: - Send
    open func send() {
        
        NetworkHelper.shared.asyncRequest(request: self) { (response) in
            
            if response.unauthorized {
                self.onUnauthorized(response: response)
                if self.authRetryCount < self.authRetryLimit {
                    self.authRetryCount += 1
                    self.reestablishAuth() { result in
                        self.send()
                    }
                    return
                }
            }
            
            if response.success {
                self.onSuccess(response: response)
            }
            
            if response.connectivityError {
                self.onConnectivityError(response: response)
                if self.connectivityRetryCount < self.connectivityRetryLimit {
                    self.connectivityRetryCount += 1
                    
                    let sleepTime = 0.6 * Double(self.connectivityRetryCount / 8) + 1
                    Thread.sleep(forTimeInterval: sleepTime)
                    self.send()
                    return
                }
            }
            
            if response.serverError {
                self.onServerError(response: response)
            }
            
            self.handler?(response)
            self.handler = nil
        }
    }
    
}


