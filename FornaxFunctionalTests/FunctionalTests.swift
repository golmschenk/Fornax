//
//  FunctionalTests.swift
//  FornaxTests
//
//  Created by Greg Olmschenk on 12/1/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import XCTest
@testable import Fornax

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

}
