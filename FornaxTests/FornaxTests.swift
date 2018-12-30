//
//  FornaxTests.swift
//  FornaxTests
//
//  Created by Greg Olmschenk on 12/1/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import XCTest
import Python
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
        XCTAssertEqual(fits.headerCards.first!.rawString, "SIMPLE  =                    T / file does conform to FITS standard             ")
    }
    
    func testHeaderCardsContainsCorrectNumberOfHeaderCards() {
        XCTAssertEqual(fits.headerCards.count, 262)
    }
    
    func testHeaderCardsContainsLastCard() {
        XCTAssertEqual(fits.headerCards.last!.rawString, "CD3_2   =                    0 /                                                ")
    }
    
    func testForPrimaryHeaderRecordCount() {
        XCTAssertEqual(fits.headerRecordCount, 8)
    }
    
    func testForArray() {
        XCTAssertNotNil(fits.array)
    }
    
    func testGettingArrayShapeFromHeader() {
        let shape = Fits.getArrayShape(fromHeaderCards: fits.headerCards)
        XCTAssertEqual(shape, [200, 200, 4])
    }
    
    func testArrayElementsAreSetFromData() {
        XCTAssertEqual(Float(fits.array[0, 0, 0])!, -1.5442986, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[1, 0, 0])!, 0.91693103, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[198, 199, 3])!, 0.7588966, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[199, 199, 3])!, 0.781659, accuracy: 1e-5)
    }
    
    func testGettingHeaderCardValueFunctionWithInt() {
        let value = fits.getHeaderCardValue(withKeyword: "NAXIS", asType: Int.self)
        XCTAssertEqual(value, 3)
    }
    
    func testGettingHeaderCardValueFunctionWithBool() {
        let value = fits.getHeaderCardValue(withKeyword: "SIMPLE", asType: Bool.self)
        XCTAssertEqual(value, true)
    }
}
