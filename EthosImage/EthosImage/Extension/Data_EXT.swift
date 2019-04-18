//
//  Data_EXT.swift
//  EthosImage
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

extension Data {
    
    var image: UIImage? {
        return UIImage(data: self)
    }
    
}
