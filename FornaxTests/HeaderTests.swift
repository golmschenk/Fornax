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

    var header: Fits.HeaderCard!

    override func setUp() {
    }

    override func tearDown() {
    }
    
    func testSplittingOfHeaderCardReturnsKeyword() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (keyword1, _, _) = Fits.HeaderCard.getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(keyword1, "SIMPLE")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (keyword2, _, _) = Fits.HeaderCard.getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(keyword2, "NAXIS")
    }
    
    func testSplittingOfHeaderCardReturnsValueString() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (_, valueString1, _) = Fits.HeaderCard.getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(valueString1, "T")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (_, valueString2, _) = Fits.HeaderCard.getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(valueString2, "3")
    }
    
    func testSplittingOfHeaderCardReturnsComment() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let (_, _, comment1) = Fits.HeaderCard.getComponents(fromCardString: headerCardString1)
        XCTAssertEqual(comment1, "file does conform to FITS standard")
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let (_, _, comment2) = Fits.HeaderCard.getComponents(fromCardString: headerCardString2)
        XCTAssertEqual(comment2, "number of data axes")
    }
    
    func testForHeaderValue() {
        let _: Fits.HeaderValue
    }
    
    func testCanGetBooleanValueFromValueString() {
        let valueString1 = "T"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .bool(let boolValue1): XCTAssertEqual(boolValue1, true)
        default: XCTFail()
        }
        let valueString2 = "F"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .bool(let boolValue2): XCTAssertEqual(boolValue2, false)
        default: XCTFail()
        }
    }
    
    func testCanGetIntValueFromFromValueString() {
        let valueString1 = "-32"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .int(let intValue1): XCTAssertEqual(intValue1, -32)
        default: XCTFail()
        }
        let valueString2 = "3"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .int(let intValue2): XCTAssertEqual(intValue2, 3)
        default: XCTFail()
        }
    }
    
    func testCanGetStringValueFromValueString() {
        let valueString1 = "'STScI-STSDAS'"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .string(let value1): XCTAssertEqual(value1, "STScI-STSDAS")
        default: XCTFail()
        }
        let valueString2 = "'u5780205r_cvt.c0h'"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .string(let value2): XCTAssertEqual(value2, "u5780205r_cvt.c0h")
        default: XCTFail()
        }
    }
    
    func testStringValueDropsTrailingWhitespace() {
        // Trailing whitespace is suppose to be ignored according to the FITS userguide.
        let valueString1 = "'STScI-STSDAS   '"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .string(let value1): XCTAssertEqual(value1, "STScI-STSDAS")
        default: XCTFail()
        }
        let valueString2 = "'u5780205r_cvt.c0h   '"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .string(let value2): XCTAssertEqual(value2, "u5780205r_cvt.c0h")
        default: XCTFail()
        }
    }
    
    func testInitilizingFromCardSetsKeyword() {
        let cardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let header = Fits.HeaderCard(fromCardString: cardString)
        XCTAssertEqual(header.keyword, "SIMPLE")
    }

    func testInitilizingFromCardSetsValue() {
        let cardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let header = Fits.HeaderCard(fromCardString: cardString)
        switch header.value {
        case .bool(let boolValue)?: XCTAssertEqual(boolValue, true)
        default: XCTFail()
        }
    }
    
    func testInitilizingFromCardSetsComment() {
        let cardString = "SIMPLE  =                    T / file does conform to FITS standard             "
        let header = Fits.HeaderCard(fromCardString: cardString)
        XCTAssertEqual(header.comment, "file does conform to FITS standard")
    }
    
    func testCanGetFloatValueFromFromValueString() {
        let valueString1 = "3.33719"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .float(let value1): XCTAssertEqual(value1, 3.33719)
        default: XCTFail()
        }
        let valueString2 = ".3543"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .float(let value2): XCTAssertEqual(value2, 0.3543)
        default: XCTFail()
        }
    }
    
    func testCanGetFloatValueWithExponentialFromFromValueString() {
        let valueString1 = "-1.086675160382E+01"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .float(let value1): XCTAssertEqual(value1, -1.086675160382e+1)
        default: XCTFail()
        }
        let valueString2 = "-1.08E-21"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .float(let value2): XCTAssertEqual(value2, -1.08e-21)
        default: XCTFail()
        }
    }
    
    func testCanGetComplexFromFromValueString() {
        let valueString1 = "-1.086675160382E+01 354"
        let value1 = Fits.HeaderCard.getValue(fromValueString: valueString1)
        switch value1 {
        case .complex(let value1):
            XCTAssertEqual(value1.real, -1.086675160382e+1)
            XCTAssertEqual(value1.imaginary, 354)
        default: XCTFail()
        }
        let valueString2 = "111     -1.08E-21"
        let value2 = Fits.HeaderCard.getValue(fromValueString: valueString2)
        switch value2 {
        case .complex(let value2):
            XCTAssertEqual(value2.real, 111)
            XCTAssertEqual(value2.imaginary, -1.08e-21)
        default: XCTFail()
        }
    }
    
    func testCanIdentifyCommentaryHeaderCards() {
        let headerCardString1 = "COMMENT   FITS (Flexible Image Transport System) format is defined in 'Astronomy"
        let boolean1 = Fits.HeaderCard.isCommentary(fromCardString: headerCardString1)
        XCTAssertTrue(boolean1)
        let headerCardString2 = "                                                                                "
        let boolean2 = Fits.HeaderCard.isCommentary(fromCardString: headerCardString2)
        XCTAssertTrue(boolean2)
        let headerCardString3 = "HISTORY   DESCRIP=STATIC MASK - INCLUDES CHARGE TRANSFER TRAPS                  "
        let boolean3 = Fits.HeaderCard.isCommentary(fromCardString: headerCardString3)
        XCTAssertTrue(boolean3)
    }
    
    func testCanIdentifyNonCommentaryHeaderCards() {
        let headerCardString1 = "SIMPLE  =                    T / file does conform to FITS standard             "
        let boolean1 = Fits.HeaderCard.isCommentary(fromCardString: headerCardString1)
        XCTAssertFalse(boolean1)
        let headerCardString2 = "NAXIS   =                    3 / number of data axes                            "
        let boolean2 = Fits.HeaderCard.isCommentary(fromCardString: headerCardString2)
        XCTAssertFalse(boolean2)
    }
    
    func testSplittingOfCommentCommentaryHeaderCardReturnsKeyword() {
        let headerCardString1 = "COMMENT   FITS (Flexible Image Transport System) format is defined in 'Astronomy"
        let (keyword1, _) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString1)
        XCTAssertEqual(keyword1, "COMMENT")
        let headerCardString2 = "COMMENT   and Astrophysics', volume 376, page 359; bibcode: 2001A&A...376..359H "
        let (keyword2, _) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString2)
        XCTAssertEqual(keyword2, "COMMENT")
    }
    
    func testSplittingOfCommentCommentaryHeaderCardReturnsCommentary() {
        let headerCardString1 = "COMMENT   FITS (Flexible Image Transport System) format is defined in 'Astronomy"
        let (_, commentary1) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString1)
        XCTAssertEqual(commentary1, "FITS (Flexible Image Transport System) format is defined in 'Astronomy")
        let headerCardString2 = "COMMENT   and Astrophysics', volume 376, page 359; bibcode: 2001A&A...376..359H "
        let (_, commentary2) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString2)
        XCTAssertEqual(commentary2, "and Astrophysics', volume 376, page 359; bibcode: 2001A&A...376..359H")
    }
    
    func testSplittingOfHistoryCommentaryHeaderCardReturnsKeyword() {
        let headerCardString1 = "HISTORY   DESCRIP=STATIC MASK - INCLUDES CHARGE TRANSFER TRAPS                  "
        let (keyword1, _) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString1)
        XCTAssertEqual(keyword1, "HISTORY")
        let headerCardString2 = "HISTORY   crotacomp$hst_ota_007_syn.fits, crwfpc2comp$wfpc2_optics_006_syn.fits,"
        let (keyword2, _) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString2)
        XCTAssertEqual(keyword2, "HISTORY")
    }
    
    func testSplittingOfHistoryCommentaryHeaderCardReturnsCommentary() {
        let headerCardString1 = "HISTORY   DESCRIP=STATIC MASK - INCLUDES CHARGE TRANSFER TRAPS                  "
        let (_, commentary1) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString1)
        XCTAssertEqual(commentary1, "DESCRIP=STATIC MASK - INCLUDES CHARGE TRANSFER TRAPS")
        let headerCardString2 = "HISTORY   crotacomp$hst_ota_007_syn.fits, crwfpc2comp$wfpc2_optics_006_syn.fits,"
        let (_, commentary2) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString2)
        XCTAssertEqual(commentary2, "crotacomp$hst_ota_007_syn.fits, crwfpc2comp$wfpc2_optics_006_syn.fits,")
    }
    
    func testSplittingOfBlankCommentaryHeaderCardReturnsKeyword() {
        let headerCardString1 = "                                                                                "
        let (keyword1, _) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString1)
        XCTAssertEqual(keyword1, "")
    }
    
    func testSplittingOfBlankCommentaryHeaderCardReturnsCommentary() {
        let headerCardString1 = "                                                                                "
        let (_, commentary1) = Fits.HeaderCard.getCommentaryComponents(fromCardString: headerCardString1)
        XCTAssertEqual(commentary1, "")
    }
}
