//
//  BaseHttpRequest_EXT.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import Alamofire

extension EthosHttpRequest {
    
    var alamo: DataRequest {
        return Alamofire.request(self.url,
                                 method: HTTPMethod(rawValue: self.method.rawValue) ?? .get,
                                 parameters: self.parameters,
                                 encoding: self.encoding,
                                 headers: self.headers)
    }
    
    private var encoding: ParameterEncoding {
        var encoding: ParameterEncoding = URLEncoding.default
        
        if let contentTypeHeader = self.headers?.get("Content-Type"),
            let contentType = ContentType.startsWith(str: contentTypeHeader) {
            switch (contentType) {
            case .json:
                encoding = JSONEncoding.default
            case .urlEncoded:
                encoding = URLEncoding.default
            case .propertyList:
                encoding = PropertyListEncoding.default
            }
        }
        
        return encoding
    }
    
}
