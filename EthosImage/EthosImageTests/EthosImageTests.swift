//
//  EthosImageTests.swift
//  EthosImageTests
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import XCTest
@testable import EthosImage
import EthosNetwork

class EthosImageTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let imageUrl = "https://cdn.vox-cdn.com/thumbor/th5YNVqlkHqkz03Va5RPOXZQRhA=/0x0:2040x1360/1200x800/filters:focal(857x517:1183x843)/cdn.vox-cdn.com/uploads/chorus_image/image/57358643/jbareham_170504_1691_0020.0.0.jpg"
        
//        let mediaResource = NetworkHelper.shared.media(url: imageUrl)
//        let mediaResource2 = NetworkHelper.shared.media(url: imageUrl, curr: mediaResource)
        let images = ImageHelper.shared.get(mediaDescriptors: [MediaDescriptor(resource: imageUrl)])
        let images2 = ImageHelper.shared.get(mediaDescriptors: [MediaDescriptor(resource: imageUrl)])
        
        print("here")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
