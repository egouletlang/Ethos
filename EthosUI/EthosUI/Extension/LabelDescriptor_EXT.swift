//
//  LabelDescriptor_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/11/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosText

extension LabelDescriptor {
    
    func removeNewLines() -> LabelDescriptor {
        guard let curr = self.attr?.string.replacingOccurrences(of: "\n", with: "") else { return self }
        self.attr = TextHelper.parse(curr)?.attr
        return self
    }
    
}
