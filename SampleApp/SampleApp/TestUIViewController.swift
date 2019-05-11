//
//  TestUIViewController.swift
//  SampleApp
//
//  Created by Etienne Goulet-Lang on 5/10/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUI

class TestUIViewController: BaseUITableViewController {
 
    override func createModels() -> [BaseRecycleModel] {
        return [
            LabelRecycleModel()
                .with(title: "hello world".b)
                .with(subtitle: "test")
                .with(details: "more")
                .with(color: UIColor.red)
                .with(minHeight: 100),
        ]
    }
    
}

