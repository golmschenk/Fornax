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
        XCTAssertNotNil(fits.headerCards)
    }
    
    func testHeaderForExampleFileLength() {
        XCTAssertNotEqual(fits.headerCards.count, 0)
    }
    
    func testHeaderContainsFirstCard() {
        XCTAssertEqual(fits.headerCards.first, "SIMPLE  =                    T / file does conform to FITS standard             ")
    }
    
    func testHeaderContainsCorrectNumberOfHeaderCards() {
        XCTAssertEqual(fits.headerCards.count, 262)
    }
    
    func testHeaderContainsLastCard() {
        XCTAssertEqual(fits.headerCards.last, "CD3_2   =                    0 /                                                ")
    }

}
