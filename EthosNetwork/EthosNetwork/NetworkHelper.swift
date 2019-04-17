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
    
    // MARK: - Builders & Constructors
    private init() {
        self.defaultQueue = DispatchQueue(label: "networking:default",
                                          qos: .background,
                                          attributes: .concurrent)
        
    }
    
    // MARK: - Singleton & Delegate
    public static let shared = NetworkHelper()
    
    // MARK: - State variables
    private let defaultQueue: DispatchQueue
    
    private var queues = [String: DispatchQueue]()
    
    // MARK: - Queue Methods
    private func getQueue(url: String) -> DispatchQueue {
        guard let host = URL(string: url)?.host else {
            return defaultQueue
        }
        return self.queues.get(self.getQueueName(host: host)) ?? defaultQueue
    }
    
    // MARK: - Request methods
    open func syncRequest(request: EthosHttpRequest, timeout: TimeInterval = 30,
                          queue: DispatchQueue? = nil) -> EthosHttpResponse? {
        let promise = Promise<EthosHttpResponse> { (promise) in
            self.asyncRequest(request: request, queue: queue) { promise.fulfill($0) }
        }
        return promise.get(timeout: timeout)
    }
    
    open func asyncRequest(request: EthosHttpRequest, queue: DispatchQueue? = nil,
                           callback: @escaping (EthosHttpResponse) -> Void) {
        let queue = queue ?? self.getQueue(url: request.url)
        request.alamo.responseData(queue: queue) { callback($0.ethosResponse) }
    }
}

public extension NetworkHelper {
    
    
    private func getQueueName(host: String) -> String {
        return "networking:\(host)"
    }
    
    func register(url: String, concurrent: Bool = true) {
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
    
    func deregister(url: String) {
        guard let host = URL(string: url)?.host else {
            return
        }
        queues.removeValue(forKey: host)
    }
    
}
