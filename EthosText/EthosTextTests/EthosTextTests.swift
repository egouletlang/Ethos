//
//  EthosTextTests.swift
//  EthosTextTests
//
//  Created by Etienne Goulet-Lang on 4/16/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import XCTest
@testable import EthosText

class EthosTextTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        var harderString = "this".b + "is".i + "a".u + "test".addColor("#884411") + "url".addLink("https://www.google.com")
        harderString = harderString.u
        
//        let link = "url".addLink("https://www.google.com")
//        let finalString = "This".b + " is a " + link
        
//        self.measure {
//            let labelDecriptor = TextHelper.formatString(finalString)
//        }
        
        let desc = TextHelper.parse(harderString)
        print("hello")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
