//
//  EthosUITests.swift
//  EthosUITests
//
//  Created by Etienne Goulet-Lang on 4/19/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import XCTest
@testable import EthosUI

class EthosUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let rect = Rect<CALayer>(CALayer(), CALayer(), CALayer(), CALayer())
        rect.left.isHidden = true
        
        let rect2 = Rect<CGFloat>(def: 0)
        rect2.left = 10
        
        print("here")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
