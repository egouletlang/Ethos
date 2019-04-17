//
//  EthosHttpRequest.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

open class EthosHttpRequest {
    
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
    
    open var showStatusNetworkSpinner = false
    
    open var url = ""
    
    open var method = Method.get
    
    open var headers: [String: String]?
    
    open var parameters: [String: Any]?
    
}
