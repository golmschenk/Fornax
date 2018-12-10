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
    
    func testForPrimaryHeaderRecordCount() {
        XCTAssertEqual(fits.headerRecordCount, 8)
    }
    
    func testCanGetBooleanValueFromHeaderCardStringForTrueCase() {
        let headerCardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let value = fits!.getHeaderCardValue(fromString: headerCardString)
        switch value {
            case .bool(let boolValue): XCTAssertEqual(boolValue, true)
            default: XCTFail()
        }
    }
    
    func testCanGetBooleanValueFromHeaderCardStringForFalseCase() {
        let headerCardString = "SIMPLE  =                    F / file does not conform to FITS standard         "
        let value = fits!.getHeaderCardValue(fromString: headerCardString)
        switch value {
            case .bool(let boolValue): XCTAssertEqual(boolValue, false)
            default: XCTFail()
        }
    }
    
    func testForHeaderValue() {
        let _: Fits.HeaderValue
    }
    
    func testCanGetIntValueFromHeaderCardString() {
        let headerCardString1 = "BITPIX  =                  -32 / number of bits per data pixel                  "
        let value1 = fits!.getHeaderCardValue(fromString: headerCardString1)
        switch value1 {
            case .int(let intValue): XCTAssertEqual(intValue, -32)
            default: XCTFail()
        }
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let value2 = fits!.getHeaderCardValue(fromString: headerCardString2)
        switch value2 {
            case .int(let intValue): XCTAssertEqual(intValue, 3)
            default: XCTFail()
        }
    }
}
