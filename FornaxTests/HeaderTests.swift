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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanGetBooleanValueFromHeaderCardStringForTrueCase() {
        let headerCardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let value = Fits.Header().getHeaderCardValue(fromString: headerCardString)
        switch value {
        case .bool(let boolValue): XCTAssertEqual(boolValue, true)
        default: XCTFail()
        }
    }
    
    func testCanGetBooleanValueFromHeaderCardStringForFalseCase() {
        let headerCardString = "SIMPLE  =                    F / file does not conform to FITS standard         "
        let value = Fits.Header().getHeaderCardValue(fromString: headerCardString)
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
        let value1 = Fits.Header().getHeaderCardValue(fromString: headerCardString1)
        switch value1 {
        case .int(let intValue): XCTAssertEqual(intValue, -32)
        default: XCTFail()
        }
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let value2 = Fits.Header().getHeaderCardValue(fromString: headerCardString2)
        switch value2 {
        case .int(let intValue): XCTAssertEqual(intValue, 3)
        default: XCTFail()
        }
    }

}
