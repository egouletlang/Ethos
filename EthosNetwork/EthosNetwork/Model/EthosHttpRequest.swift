//
//  EthosHttpRequest.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class EthosHttpRequest {
    
    // MARK: - Constants & Types
    public enum ContentType: String {
        case json = "application/json"
        case propertyList = "application/x-plist"
        case urlEncoded = "application/x-www-form-urlencoded"
        
        public static func startsWith(str: String) -> ContentType? {
            if json.rawValue.startsWith(str) { return json }
            if urlEncoded.rawValue.startsWith(str) { return urlEncoded }
            if propertyList.rawValue.startsWith(str) { return propertyList }
            return nil
        }
    }
    
    public enum Method: String {
        case delete = "DELETE"
        case get = "GET"
        case head = "HEAD"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
    }
    
    // MARK: - Builders & Constructors
    public init(url: String, method: Method = .get, headers: [String: String]? = nil,
                parameters: [String: Any]? = nil) {
        self.url = url
        self.method = method
        self.headers = headers
        self.parameters = parameters
    }
    
    open func with(networkSpinner: Bool) -> EthosHttpRequest {
        self.showStatusNetworkSpinner = networkSpinner
        return self
    }
    
    open func with(url: String) -> EthosHttpRequest {
        self.url = url
        return self
    }
    
    open func with(method: Method) -> EthosHttpRequest {
        self.method = method
        return self
    }
    
    open func with(headers: [String: String]?) -> EthosHttpRequest {
        self.headers = headers
        return self
    }
    
    open func add(header: String, value: String) -> EthosHttpRequest {
        if headers == nil {
            headers = [:]
        }
        headers?[header] = value
        return self
    }
    
    open func with(parameters: [String: Any]?) -> EthosHttpRequest {
        self.parameters = parameters
        return self
    }
    
    open func add(parameter: String, value: Any) -> EthosHttpRequest {
        if parameters == nil {
            parameters = [:]
        }
        parameters?[parameter] = value
        return self
    }
    
    // MARK: - State variables
    open var showStatusNetworkSpinner = false
    
    open var url = ""
    
    open var method = Method.get
    
    open var headers: [String: String]?
    
    open var parameters: [String: Any]?
    
}
