//
//  Fits.swift
//  Fornax
//
//  Created by Greg Olmschenk on 12/2/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import Foundation

struct Fits {

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
}

extension Fits {
    struct Header {
        func getHeaderCardValue(fromString headerCardString: String) -> HeaderValue {
            let keywordSplit = headerCardString.split(separator: "=", maxSplits: 1)
            //let keyword = String(keywordSplit.first!)
            let valueSplit = keywordSplit.last!.split(separator: "/", maxSplits: 1)
            let valueSubstring = valueSplit.first!.trimmingCharacters(in: .whitespaces)
            //let comment = String(valueSplit.last!)
            if valueSubstring == "T" {
                return HeaderValue.bool(true)
            } else if valueSubstring == "F" {
                return HeaderValue.bool(false)
            } else {
                return HeaderValue.int(Int(valueSubstring)!)
            }
        }
    }
    
    enum HeaderValue {
        case bool(Bool)
        case int(Int)
    }
}
