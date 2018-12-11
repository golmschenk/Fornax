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

    var url: URL!
    var fits: Fits!
    
    override func setUp() {
        let bundle = Bundle(for: type(of: self))
        url = bundle.url(forResource: "ExampleFitsFile", withExtension: "fits")!
        fits = Fits(fromUrl: url)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForFits() {
        let _ = Fits(fromUrl: url)
    }
    
    func testForHeaderCards() {
        XCTAssertNotNil(fits.headerCards)
    }
    
    func testHeaderCardsForExampleFileLength() {
        XCTAssertNotEqual(fits.headerCards.count, 0)
    }
    
    func testHeaderCardsContainsFirstCard() {
        XCTAssertEqual(fits.headerCards.first, "SIMPLE  =                    T / file does conform to FITS standard             ")
    }
    
    func testHeaderCardsContainsCorrectNumberOfHeaderCards() {
        XCTAssertEqual(fits.headerCards.count, 262)
    }
    
    func testHeaderCardsContainsLastCard() {
        XCTAssertEqual(fits.headerCards.last, "CD3_2   =                    0 /                                                ")
    }
    
    func testForPrimaryHeaderRecordCount() {
        XCTAssertEqual(fits.headerRecordCount, 8)
    }
}
