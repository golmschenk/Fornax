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

let 🐛 = Python.slice(Python.None, Python.None, Python.None)

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
        XCTAssertEqual(Float(fits.array[0, 0, 1])!, 0.91693103, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[3, 199, 198])!, 0.7588966, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[3, 199, 199])!, 0.781659, accuracy: 1e-5)
    }
    
    func testGettingHeaderCardValueFunctionWithInt() {
        let value = fits.getHeaderCardValue(withKeyword: "NAXIS", asType: Int.self)
        XCTAssertEqual(value, 3)
    }
    
    func testGettingHeaderCardValueFunctionWithBool() {
        let value = fits.getHeaderCardValue(withKeyword: "SIMPLE", asType: Bool.self)
        XCTAssertEqual(value, true)
    }
    
    func testGettingHeaderCardValueFunctionWithFloat() {
        let value = fits.getHeaderCardValue(withKeyword: "CD1_1", asType: Float64.self)
        XCTAssertEqual(value, -1.067040E-6, accuracy: 1e-10)
    }
    
    func testGettingHeaderCardValueFunctionWithString() {
        let value = fits.getHeaderCardValue(withKeyword: "FITSDATE", asType: String.self)
        XCTAssertEqual(value, "2004-01-09")
    }
    
    func testGettingHeaderCardValueFunctionWithComplex() {
        fits.headerCards.append(Fits.HeaderCard(fromCardString: "COMPLEX = 1 2"))
        let value = fits.getHeaderCardValue(withKeyword: "COMPLEX", asType: Fits.HeaderValue.Complex.self)
        XCTAssertEqual(value, Fits.HeaderValue.Complex(real: 1, imaginary: 2))
    }
    
    func testGettingHeaderCardValueFunctionWithStaticFunction() {
        let value = Fits.getHeaderCardValue(fromHeaderCards: fits.headerCards, withKeyword: "NAXIS", asType: Int.self)
        XCTAssertEqual(value, 3)
    }
    
    func testApplyingColorMapToArray() {
        let frame = fits.array[0, 🐛, 🐛]
        let imageArray = Fits.color(array: frame)
        XCTAssertEqual(imageArray[74, 104].map {UInt8($0)!}, [253, 231, 36, 255])
        XCTAssertEqual(imageArray[187, 18].map {UInt8($0)!}, [68, 1, 84, 255])
        XCTAssertEqual(imageArray[0, 0].map {UInt8($0)!}, [68, 1, 84, 255])
    }
}
