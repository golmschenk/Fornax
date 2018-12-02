//
//  FornaxTests.swift
//  FornaxTests
//
//  Created by Greg Olmschenk on 12/1/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import XCTest
@testable import Fornax

class FornaxTests: XCTestCase {

    var path: String!
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        path = bundle.path(forResource: "ExampleFitsFile", ofType: "fits")!
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForFits() {
        let _ = Fits(fromPath: path)
    }
    
    func testHeaderContainsDataWhenLoadingFile() {
        let fits = Fits(fromPath: path)
        XCTAssertNotNil(fits.header)
    }

}
