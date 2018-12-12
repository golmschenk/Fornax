//
//  HeaderTests.swift
//  FornaxTests
//
//  Created by Greg Olmschenk on 12/10/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import XCTest
@testable import Fornax

class HeaderTests: XCTestCase {

    var header: Fits.Header!

    override func setUp() {
    }

    override func tearDown() {
    }
    
    func testSplittingOfHeaderCardReturnsKeyword() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (keyword1, _, _) = Fits.Header.getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(keyword1, "SIMPLE")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (keyword2, _, _) = Fits.Header.getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(keyword2, "NAXIS")
    }
    
    func testSplittingOfHeaderCardReturnsValueString() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (_, valueString1, _) = Fits.Header.getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(valueString1, "T")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (_, valueString2, _) = Fits.Header.getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(valueString2, "3")
    }
    
    func testSplittingOfHeaderCardReturnsComment() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (_, _, comment1) = Fits.Header.getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(comment1, "file does conform to FITS standard")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (_, _, comment2) = Fits.Header.getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(comment2, "number of data axes")
    }
    
    func testForHeaderValue() {
        let _: Fits.HeaderValue
    }
    
    func testCanGetBooleanValueFromValueString() {
        let valueString1 = "T"
        let value1 = Fits.Header.getValue(fromValueString: valueString1)
        switch value1 {
        case .bool(let boolValue1): XCTAssertEqual(boolValue1, true)
        default: XCTFail()
        }
        let valueString2 = "F"
        let value2 = Fits.Header.getValue(fromValueString: valueString2)
        switch value2 {
        case .bool(let boolValue2): XCTAssertEqual(boolValue2, false)
        default: XCTFail()
        }
    }
    
    func testCanGetIntValueFromFromValueString() {
        let valueString1 = "-32"
        let value1 = Fits.Header.getValue(fromValueString: valueString1)
        switch value1 {
        case .int(let intValue1): XCTAssertEqual(intValue1, -32)
        default: XCTFail()
        }
        let valueString2 = "3"
        let value2 = Fits.Header.getValue(fromValueString: valueString2)
        switch value2 {
        case .int(let intValue2): XCTAssertEqual(intValue2, 3)
        default: XCTFail()
        }
    }
    
    func testCanGetStringValueFromValueString() {
        let valueString1 = "'STScI-STSDAS'"
        let value1 = Fits.Header.getValue(fromValueString: valueString1)
        switch value1 {
        case .string(let value1): XCTAssertEqual(value1, "STScI-STSDAS")
        default: XCTFail()
        }
        let valueString2 = "'u5780205r_cvt.c0h'"
        let value2 = Fits.Header.getValue(fromValueString: valueString2)
        switch value2 {
        case .string(let value2): XCTAssertEqual(value2, "u5780205r_cvt.c0h")
        default: XCTFail()
        }
    }
    
    func testStringValueDropsTrailingWhitespace() {
        // Trailing whitespace is suppose to be ignored according to the FITS userguide.
        let valueString1 = "'STScI-STSDAS   '"
        let value1 = Fits.Header.getValue(fromValueString: valueString1)
        switch value1 {
        case .string(let value1): XCTAssertEqual(value1, "STScI-STSDAS")
        default: XCTFail()
        }
        let valueString2 = "'u5780205r_cvt.c0h   '"
        let value2 = Fits.Header.getValue(fromValueString: valueString2)
        switch value2 {
        case .string(let value2): XCTAssertEqual(value2, "u5780205r_cvt.c0h")
        default: XCTFail()
        }
    }
    
    func testInitilizingFromCardSetsKeyword() {
        let cardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let header = Fits.Header(fromCardString: cardString)
        XCTAssertEqual(header.keyword, "SIMPLE")
    }

    func testInitilizingFromCardSetsValue() {
        let cardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let header = Fits.Header(fromCardString: cardString)
        switch header.value {
        case .bool(let boolValue)?: XCTAssertEqual(boolValue, true)
        default: XCTFail()
        }
    }
    
    func testInitilizingFromCardSetsComment() {
        let cardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let header = Fits.Header(fromCardString: cardString)
        XCTAssertEqual(header.comment, "file does conform to FITS standard")
    }
    
    func testCanGetFloatValueFromFromValueString() {
        let valueString1 = "3.33719"
        let value1 = Fits.Header.getValue(fromValueString: valueString1)
        switch value1 {
        case .float(let value1): XCTAssertEqual(value1, 3.33719)
        default: XCTFail()
        }
        let valueString2 = ".3543"
        let value2 = Fits.Header.getValue(fromValueString: valueString2)
        switch value2 {
        case .float(let value2): XCTAssertEqual(value2, 0.3543)
        default: XCTFail()
        }
    }
    
}
