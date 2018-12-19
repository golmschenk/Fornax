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
    
    var path:String!

    override func setUp() {
    }

    override func tearDown() {
    }

    func testCanReadBasicFitsHeaderInformation() {
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "ExampleFitsFile", withExtension: "fits")!
        let fits = Fits(fromUrl: url)
        XCTAssertEqual(fits.headerCards.first {$0.keyword == "NAXIS"}, 3)
        XCTAssertEqual(fits.headerCards.first {$0.keyword == "NAXIS1"}, 200)
        XCTFail("Finish the test!")
    }

}
