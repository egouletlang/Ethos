//
//  EthosHttpResponse.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import SwiftyJSON
import EthosUtil

open class EthosHttpResponse {
    
    public enum Error: Int {
        case BadRequest = -100
        case Connectivity = -110
    }
    
    public static func buildBadRequest(msg: String?) -> EthosHttpResponse {
        let resp = EthosHttpResponse(statusCode: Error.BadRequest.rawValue)
        resp.description = msg
        return resp
    }
    
    public static func buildConnectivityError(msg: String?) -> EthosHttpResponse {
        let resp = EthosHttpResponse(statusCode: Error.Connectivity.rawValue)
        resp.description = msg
        return resp
    }
    
    public init (statusCode: Int) {
        self.statusCode = statusCode
    }
    
    public init (response: HTTPURLResponse, data: Data?) {
        self.statusCode = response.statusCode
        self.headers = response.allHeaderFields as? [String: Any]
        self.data = data
    }
    
    public let statusCode: Int!
    
    public var headers: [String: Any]?
    
    open var data: Data?
    
    open var body: JSON? {
        guard let d = data else {
            return nil
        }
        return JSON(d).removeEmptyKeys()
    }
    
    open var image: UIImage? {
        guard let d = data else {
            return nil
        }
        return UIImage(data: d)
    }
    
    open var errorMessage: String? {
        if self.success {
            return nil
        } else if self.connectivityError {
            return "Connectivity Error"
        } else if self.unauthorized {
            return "Authentication Error"
        } else if self.serverError {
            return "Server Error"
        } else if self.badRequest {
            return "Client Error"
        }
        return "Unknown Error"
    }
    
    open var description: String?
    
    open var success: Bool {
        return (statusCode / 100 == 2)
    }
    
    open var apiError: Bool {
        return (statusCode / 100 == 4)
    }
    
    open var serverError: Bool {
        return (statusCode / 100 == 5)
    }
    
    open var badRequest: Bool {
        return (statusCode == Error.BadRequest.rawValue)
    }
    
    open var connectivityError: Bool {
        return (statusCode == Error.Connectivity.rawValue)
    }
    
    open var unauthorized: Bool {
        return (statusCode == 403 || statusCode == 401)
    }
    
}
