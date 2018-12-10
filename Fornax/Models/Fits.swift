//
//  Fits.swift
//  Fornax
//
//  Created by Greg Olmschenk on 12/2/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import Foundation

class Fits {

    static let headerCardLength = 80
    static let recordLength = 2880
    static let cardsPerRecord = 36
    
    var headerRecordCount = 0
    var headerCards = [String]()
    
    init(fromUrl fileUrl: URL) {
        var bytes = [UInt8]()
        let data = try! Data(contentsOf: fileUrl)
        for headerCardStartIndex in stride(from: 0, to: data.count, by: Fits.headerCardLength)
        {
            bytes = Array(data[headerCardStartIndex ..< headerCardStartIndex + Fits.headerCardLength])
            let string = String(bytes: bytes, encoding: .ascii)!
            if string.prefix(3) == "END" {
                headerRecordCount = (headerCardStartIndex / Fits.recordLength) + 1
                break
            }
            else {
                headerCards.append(string)
            }
        }
    }
    
    func getHeaderCardValue(fromString headerCardString: String) -> Bool {
        let boolean_index = headerCardString.index(headerCardString.startIndex, offsetBy: 29)
        if headerCardString[boolean_index] == "T" {
            return true
        } else {
            return false
        }
    }
}

extension Fits {
    enum HeaderType {
        
    }
}
