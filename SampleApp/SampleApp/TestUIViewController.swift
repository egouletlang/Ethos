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
                .with(color: UIColor.red),
            
            LabelRecycleModel()
                .with(title: "hello world".b)
                .with(subtitle: "test")
                .with(details: "more"),
            
            LabelRecycleModel()
                .with(title: "hello world".b)
                .withPadding(left: 10, top: 10, right: 10, bottom: 10)
                .with(color: UIColor.red)
        ]
    }
    
}

