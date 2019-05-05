//
//  ComponentState.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/5/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public class ComponentState {
    
    var state = [String: Any]()
    
    public func getHandle<T>(handle: VariableHandle<T>) -> VariableHandle<T> {
        return self.state.get(handle.key) { () -> Any? in
            return handle.newInstance()
        } as! VariableHandle<T>
    }
    
    public func clone() -> ComponentState {
        let clone = ComponentState()
        clone.state = self.state
        return clone
    }
}
