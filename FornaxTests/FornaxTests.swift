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
    var fits: Fits!
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        path = bundle.path(forResource: "ExampleFitsFile", ofType: "fits")!
        fits = Fits(fromPath: path)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForFits() {
        let _ = Fits(fromPath: path)
    }
    
    func testForHeader() {
        XCTAssertNotNil(fits.header)
    }
    
    func testHeaderForExampleFileLength() {
        XCTAssertNotEqual(fits.header.count, 0)
    }
    
    func testHeaderContainsFirstCard() {
        XCTAssertEqual(fits.header[0], "SIMPLE  =                    T / file does conform to FITS standard             ")
    }
    
    func testHeaderContainsCorrectNumberOfHeaderCards() {
        XCTAssertEqual(fits.header.count, 262)
    }

}
