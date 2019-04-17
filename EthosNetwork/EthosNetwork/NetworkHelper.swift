//
//  NetworkHelper.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil
import Alamofire

open class NetworkHelper {
    
    private init() {
        self.defaultQueue = DispatchQueue(label: "networking:default",
                                          qos: .background,
                                          attributes: .concurrent)
    }
    
    public static let shared = NetworkHelper()
    
    private var defaultQueue: DispatchQueue
    
    private var queues = [String: DispatchQueue]()
    
    private func getQueue(url: String) -> DispatchQueue {
        guard let host = URL(string: url)?.host else {
            return defaultQueue
        }
        return self.queues.get(self.getQueueName(host: host)) ?? defaultQueue
    }
    
    private func getQueueName(host: String) -> String {
        return "networking:\(host)"
    }
    
    open func register(url: String, concurrent: Bool = true) {
        guard let host = URL(string: url)?.host else {
            return
        }
        
        if concurrent {
            queues.set(host, DispatchQueue(label: self.getQueueName(host: host), qos: .background,
                                           attributes: .concurrent))
        } else {
            queues.set(host, DispatchQueue(label: self.getQueueName(host: host), qos: .background))
        }
    }
    
    open func deregister(url: String) {
        guard let host = URL(string: url)?.host else {
            return
        }
        queues.removeValue(forKey: host)
    }
    
    open func syncRequest(request: EthosHttpRequest, timeout: TimeInterval = 30) -> EthosHttpResponse? {
        let promise = Promise<EthosHttpResponse> { (promise) in
            self.asyncRequest(request: request) { promise.fulfill($0) }
        }
        return promise.get(timeout: timeout)
    }
    
    open func asyncRequest(request: EthosHttpRequest, callback: @escaping (EthosHttpResponse) -> Void) {
        request.alamo.responseData(queue: self.getQueue(url: request.url)) { response in
            callback(response.ethosResponse)
        }
    }

}
