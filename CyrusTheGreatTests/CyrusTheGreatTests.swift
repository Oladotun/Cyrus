//
//  CyrusTheGreatTests.swift
//  CyrusTheGreatTests
//
//  Created by Dotun Opasina on 2/16/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import XCTest
@testable import CyrusTheGreat

class CyrusTheGreatTests: XCTestCase {
    var myModel: FirebaseManager!
    
    override func setUp() {
        super.setUp()
        self.myModel = FirebaseManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMeetUpSetAtBeginning() {
        myModel = FirebaseManager()
        XCTAssert(!myModel.meetUpSet,"Created")
        
    }
    
    func testUserObjectNotNill() {
        myModel = FirebaseManager()
        myModel.setUpCurrentUser("46a49580-3df3-4c21-af70-f623fd3095e3")
        
        XCTAssert(myModel.userObject != nil,"Not nil")
//        XCTAssert(myModel.userObject.firstName != nil, "FirstName not null")
    }
    
//    func testExample() {
//        // This is an example of a functional test case.
//        XCTAssert(true, "Pass")
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
