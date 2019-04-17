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
        self._url = url
        self._method = method
        self._headers = headers
        self._parameters = parameters
    }
    
    open func with(networkSpinner: Bool) -> EthosHttpRequest {
        self._network = networkSpinner
        return self
    }
    
    open func with(url: String) -> EthosHttpRequest {
        self._url = url
        return self
    }
    
    open func with(method: Method) -> EthosHttpRequest {
        self._method = method
        return self
    }
    
    open func with(headers: [String: String]?) -> EthosHttpRequest {
        self._headers = headers
        return self
    }
    
    open func add(header: String, value: String) -> EthosHttpRequest {
        if _headers == nil {
            _headers = [:]
        }
        _headers?[header] = value
        return self
    }
    
    open func with(parameters: [String: Any]?) -> EthosHttpRequest {
        self._parameters = parameters
        return self
    }
    
    open func add(parameter: String, value: Any) -> EthosHttpRequest {
        if _parameters == nil {
            _parameters = [:]
        }
        _parameters?[parameter] = value
        return self
    }
    
    // MARK: - State variables
    fileprivate var _network = false
    
    fileprivate var _url = ""
    
    fileprivate var _method = Method.get
    
    fileprivate var _headers: [String: String]?
    
    fileprivate var _parameters: [String: Any]?
    
    
    open var showStatusNetworkSpinner: Bool {
        return _network
    }
    
    open var url: String {
        return _url
    }
    
    open var method: Method {
        return _method
    }
    
    open var headers: [String: String]? {
        return _headers
    }
    
    open var parameters: [String: Any]? {
        return _parameters
    }
    
}
