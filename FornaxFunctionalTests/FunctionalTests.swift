//
//  FunctionalTests.swift
//  FornaxTests
//
//  Created by Greg Olmschenk on 12/1/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import XCTest
import Python
@testable import Fornax

let 🐛 = Python.slice(Python.None, Python.None, Python.None)

class FunctionalTests: XCTestCase {
    
    override func setUp() {
    }

    override func tearDown() {
    }

    func testCanReadBasicFitsHeaderInformation() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "ExampleFitsFile", withExtension: "fits")!
        let fits = Fits(fromUrl: url)
        let naxisCardValue = fits.headerCards.first{$0.keyword == "NAXIS"}!.value
        switch naxisCardValue {
        case .int(let intValue): XCTAssertEqual(intValue, 3)
        default: XCTFail()
        }
        let naxis1CardValue = fits.headerCards.first{$0.keyword == "NAXIS1"}!.value
        switch naxis1CardValue {
        case .int(let intValue): XCTAssertEqual(intValue, 200)
        default: XCTFail()
        }
    }
    
    func testCanReadBasicFitsArrayData() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "ExampleFitsFile", withExtension: "fits")!
        let fits = Fits(fromUrl: url)
        XCTAssertEqual(Float(fits.array[0, 0, 0])!, -1.5442986, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[1, 0, 0])!, 0.91693103, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[198, 199, 3])!, 0.7588966, accuracy: 1e-5)
        XCTAssertEqual(Float(fits.array[199, 199, 3])!, 0.781659, accuracy: 1e-5)
    }
    
    func testCanReadFitsArrayDataAsLinearGrayScaleImage() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "ExampleFitsFile", withExtension: "fits")!
        let fits = Fits(fromUrl: url)
        let frame = fits.array[🐛, 🐛, 0]
        let imageArray = Fits.color(array: frame)
        XCTAssertEqual(frame[1, 158].map {Float($0)!}, [1, 1, 1, 1])
        XCTFail("Finish the test!")
    }
}
