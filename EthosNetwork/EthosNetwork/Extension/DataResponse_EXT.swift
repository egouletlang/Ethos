//
//  DataResponse_EXT.swift
//  EthosNetwork
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import Alamofire

extension DataResponse {
    
    var ethosResponse: EthosHttpResponse {
        guard let httpUrlResponse = self.response else {
            return EthosHttpResponse.buildConnectivityError(msg: nil)
        }
        return EthosHttpResponse(response: httpUrlResponse, data: self.data)
    }
    
}
