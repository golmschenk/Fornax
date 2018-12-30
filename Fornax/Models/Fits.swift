//
//  Fits.swift
//  Fornax
//
//  Created by Greg Olmschenk on 12/2/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import Foundation
import Python

let np = Python.import("numpy")  // Not sure how I feel about this being a global, but referring to NumPy just as `np` makes the code much more clear.

struct Fits {

    static let headerCardLength = 80
    static let recordLength = 2880
    static let cardsPerRecord = 36
    
    var headerRecordCount = 0
    var headerCards = [HeaderCard]()
    var array: PythonObject
    
    init(fromUrl fileUrl: URL) {
        var bytes = [UInt8]()
        let data = try! Data(contentsOf: fileUrl)
        for headerCardStartIndex in stride(from: 0, to: data.count, by: Fits.headerCardLength)
        {
            bytes = Array(data[headerCardStartIndex ..< headerCardStartIndex + Fits.headerCardLength])
            let headerCardString = String(bytes: bytes, encoding: .ascii)!
            if headerCardString.prefix(3) == "END" {
                headerRecordCount = (headerCardStartIndex / Fits.recordLength) + 1
                break
            }
            else {
                headerCards.append(HeaderCard(fromCardString: headerCardString))
            }
        }
        let arrayShape = Fits.getArrayShape(fromHeaderCards: headerCards)
        let arrayDataStart = headerRecordCount * Fits.recordLength
        let bitpixCardValue = headerCards.first{$0.keyword == "BITPIX"}!.value
        let bitpix: Int
        switch bitpixCardValue {
        case .int(let intValue):
            bitpix = intValue
        default:
            fatalError("BITPIX was not an integer. It was \(bitpixCardValue)")
        }
        let arrayDataEnd = arrayShape.reduce(abs(bitpix) / 8, *) + arrayDataStart
        let arrayData = data.subdata(in: arrayDataStart..<arrayDataEnd)
        switch bitpix {
        case -32: // float32
            let swiftSwappedFloatArray = arrayData.toArray(type: CFSwappedFloat32.self)
            let swiftFloatArray = swiftSwappedFloatArray.map(CFConvertFloat32SwappedToHost)
            array = np.array(swiftFloatArray, np.float32).reshape(arrayShape, order: "F")
        default:
            fatalError("BITPIX was not a valid value. It was \(bitpix)")
        }
    }
    
    static func getArrayShape(fromHeaderCards headerCards: [HeaderCard]) -> [Int] {
        let naxisCardValue = headerCards.first{$0.keyword == "NAXIS"}!.value
        let numberOfAxes: Int
        switch naxisCardValue {
        case .int(let intValue):
            numberOfAxes = intValue
        default:
            fatalError("NAXIS was not an integer. It was \(naxisCardValue)")
        }
        var shape = [Int]()
        for n in 1 ... numberOfAxes {
            let axisCardValue = headerCards.first{$0.keyword == "NAXIS\(n)"}!.value
            switch axisCardValue {
            case .int(let intValue):
                shape.append(intValue)
            default:
                fatalError("NAXIS\(n) was not an integer. It was \(axisCardValue)")
            }
        }
        return shape
    }
}

extension Fits {
    struct HeaderCard {
        let keyword: String
        let value: HeaderValue
        let comment: String
        let rawString: String
        
        init(fromCardString cardString: String) {
            let valueString: String
            if Fits.HeaderCard.isCommentary(fromCardString: cardString) {
                (keyword, valueString) = Fits.HeaderCard.getCommentaryComponents(fromCardString: cardString)
                value = HeaderValue.string(String(valueString))
                comment = ""
            } else {
                (keyword, valueString, comment) = Fits.HeaderCard.getComponents(fromCardString: cardString)
                value = Fits.HeaderCard.getValue(fromValueString: valueString)
            }
            rawString = cardString
        }
        
        static func getValue(fromValueString valueString: String) -> HeaderValue {
            if valueString.first == "'" && valueString.last == "'" {
                let stringContent = valueString.dropFirst().dropLast()
                let contentWithoutTrailingWhitespace = stringContent.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
                return HeaderValue.string(String(contentWithoutTrailingWhitespace))
            } else if valueString == "T" {
                return HeaderValue.bool(true)
            } else if valueString == "F" {
                return HeaderValue.bool(false)
            } else {  // Is a number.
                let splitValueString = valueString.split(separator: " ", omittingEmptySubsequences: true)
                if splitValueString.count == 2 {  // Complex number.
                    return HeaderValue.complex(Fits.HeaderValue.Complex(real: Float64(splitValueString.first!), imaginary: Float64(splitValueString.last!)))
                } else if valueString.contains(".") {  // Float.
                    return HeaderValue.float(Float64(valueString)!)
                } else {  // Integer
                    return HeaderValue.int(Int(valueString)!)
                }
            }
        }

        static func getComponents(fromCardString cardString: String) -> (String, String, String) {
            let keywordSplit = cardString.split(separator: "=", maxSplits: 1)
            let keyword = keywordSplit.first!.trimmingCharacters(in: .whitespaces)
            let valueSplit = keywordSplit.last!.split(separator: "/", maxSplits: 1)
            let valueSubstring = valueSplit.first!.trimmingCharacters(in: .whitespaces)
            let comment: String
            if valueSplit.count == 1 {
                comment = ""
            } else {
                comment = valueSplit.last!.trimmingCharacters(in: .whitespaces)
            }
            return (keyword, valueSubstring, comment)
        }
        
        static func getCommentaryComponents(fromCardString cardString: String) -> (String, String) {
            let keywordSplit = cardString.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: false)
            let keyword = keywordSplit.first!.trimmingCharacters(in: .whitespaces)
            let commentary = keywordSplit.last!.trimmingCharacters(in: .whitespaces)
            return (keyword, commentary)
        }
        
        static func isCommentary(fromCardString cardString: String) -> Bool {
            if cardString.hasPrefix("COMMENT") {
                return true
            } else if cardString.hasPrefix("HISTORY") {
                return true
            } else if cardString.hasPrefix("        ") {
                return true
            } else {
                return false
            }
        }
    }
    
    enum HeaderValue {
        case bool(Bool)
        case int(Int)
        case string(String)
        case float(Float64)
        case complex(Complex)
        
        struct Complex {
            let real: Float64!
            let imaginary: Float64!
        }
    }
}

extension Data {  // Taken from https://stackoverflow.com/a/38024025/1191087
    init<T>(fromArray values: [T]) {
        self = values.withUnsafeBytes { Data($0) }
    }
        
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }
}
