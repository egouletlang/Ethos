//
//  TestUIViewController.swift
//  SampleApp
//
//  Created by Etienne Goulet-Lang on 5/10/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUI
import EthosImage

class TestUIViewController: BaseUITableViewController {
 
    override func createLayout() -> LifeCycleInterface {
        super.createLayout()
        
        self.addPullToRefresh(image: UIImage(named: "down_arrow.png")) {
            print("here2")
            Thread.sleep(forTimeInterval: 3)
            
        }
        return self
    }
    
    override func createModels() -> [BaseRecycleModel] {
        return [
            LabelRecycleModel()
                .with(title: "hello world".b)
                .with(subtitle: "test")
                .with(details: "more".addLink("https://www.google.com"))
                .with(click: "Testing"),
            BaseRecycleModel()
                .with(height: 40)
                .with(color: UIColor.red)
                .with(click: "MORE")
        ]
    }
    
    
    override func tapped(model: BaseRecycleModel, view: BaseRecycleView, tableview: BaseUITableView) {
        print("here")
    }
}

