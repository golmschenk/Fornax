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
    
    func testSplittingOfHeaderCardReturnsKeyword() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (keyword1, _, _) = Fits.Header().getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(keyword1, "SIMPLE")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (keyword2, _, _) = Fits.Header().getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(keyword2, "NAXIS")
    }
    
    func testSplittingOfHeaderCardReturnsValueString() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (_, valueString1, _) = Fits.Header().getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(valueString1, "T")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (_, valueString2, _) = Fits.Header().getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(valueString2, "3")
    }
    
    func testSplittingOfHeaderCardReturnsComment() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (_, _, comment1) = Fits.Header().getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(comment1, "file does conform to FITS standard")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (_, _, comment2) = Fits.Header().getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(comment2, "number of data axes")
    }
    
    func testForHeaderValue() {
        let _: Fits.HeaderValue
    }
    
    func testCanGetBooleanValueFromValueString() {
        let valueString1 = "T"
        let value1 = Fits.Header().getValue(fromValueString: valueString1)
        switch value1 {
        case .bool(let boolValue1): XCTAssertEqual(boolValue1, true)
        default: XCTFail()
        }
        let valueString2 = "F"
        let value2 = Fits.Header().getValue(fromValueString: valueString2)
        switch value2 {
        case .bool(let boolValue2): XCTAssertEqual(boolValue2, false)
        default: XCTFail()
        }
    }
    
    func testCanGetIntValueFromHeaderCardString() {
        let valueString1 = "-32"
        let value1 = Fits.Header().getValue(fromValueString: valueString1)
        switch value1 {
        case .int(let intValue1): XCTAssertEqual(intValue1, -32)
        default: XCTFail()
        }
        let valueString2 = "3"
        let value2 = Fits.Header().getValue(fromValueString: valueString2)
        switch value2 {
        case .int(let intValue2): XCTAssertEqual(intValue2, 3)
        default: XCTFail()
        }
    }

}
