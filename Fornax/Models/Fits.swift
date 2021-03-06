//
//  Fits.swift
//  Fornax
//
//  Created by Greg Olmschenk on 12/2/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import Foundation
import Python
import AppKit

let np = Python.import("numpy")  // Not sure how I feel about this being a global, but referring to NumPy just as `np` makes the code much more clear.
let matPlotLibPlt = Python.import("matplotlib.pyplot")

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
        let bitpix = Fits.getHeaderCardValue(fromHeaderCards: headerCards, withKeyword: "BITPIX", asType: Int.self)
        let arrayDataEnd = arrayShape.reduce(abs(bitpix) / 8, *) + arrayDataStart
        let arrayData = data.subdata(in: arrayDataStart..<arrayDataEnd)
        switch bitpix {
        case -32: // float32
            let swiftSwappedFloatArray = arrayData.toArray(type: CFSwappedFloat32.self)
            let swiftFloatArray = swiftSwappedFloatArray.map(CFConvertFloat32SwappedToHost)
            array = np.array(swiftFloatArray, np.float32).reshape(arrayShape, order: "F")
            array = np.transpose(array)  // Switch from Fortran order to C order.
        default:
            fatalError("BITPIX was not a valid value. It was \(bitpix)")
        }
    }
    
    static func getArrayShape(fromHeaderCards headerCards: [Fits.HeaderCard]) -> [Int] {
        let numberOfAxes = Fits.getHeaderCardValue(fromHeaderCards: headerCards, withKeyword: "NAXIS", asType: Int.self)
        var shape = [Int]()
        for n in 1 ... numberOfAxes {
            shape.append(Fits.getHeaderCardValue(fromHeaderCards: headerCards, withKeyword: "NAXIS\(n)", asType: Int.self))
        }
        return shape
    }
    
    func getHeaderCardValue<T>(withKeyword keyword: String, asType type: T.Type) -> T {
        return Fits.getHeaderCardValue(fromHeaderCards: headerCards, withKeyword: keyword, asType: type)
    }
    
    static func getHeaderCardValue<T>(fromHeaderCards headerCards: [Fits.HeaderCard], withKeyword keyword: String, asType type: T.Type) -> T {
        let cardValue = headerCards.first{$0.keyword == keyword}!.value
        switch type {
        case is Int.Type:
            switch cardValue {
            case .int(let intValue):
                return intValue as! T
            default:
                fatalError("\(keyword) was not an integer. It was \(cardValue)")
            }
        case is Bool.Type:
            switch cardValue {
            case .bool(let boolValue):
                return boolValue as! T
            default:
                fatalError("\(keyword) was not a boolean. It was \(cardValue)")
            }
        case is Float64.Type:
            switch cardValue {
            case .float(let floatValue):
                return floatValue as! T
            default:
                fatalError("\(keyword) was not a float. It was \(cardValue)")
            }
        case is String.Type:
            switch cardValue {
            case .string(let stringValue):
                return stringValue as! T
            default:
                fatalError("\(keyword) was not a complex number. It was \(cardValue)")
            }
        case is Fits.HeaderValue.Complex.Type:
            switch cardValue {
            case .complex(let complexValue):
                return complexValue as! T
            default:
                fatalError("\(keyword) was not a. It was \(cardValue)")
            }
        default:
            fatalError("\(type) is not a known header card type.")
        }
    }
    
    static func color(array: PythonObject) -> PythonObject
    {
        let colorMap = matPlotLibPlt.get_cmap("viridis")
        let scalarMap = matPlotLibPlt.cm.ScalarMappable(cmap: colorMap)
        let colorsArray = scalarMap.to_rgba(array, bytes: true, norm: true)
        return colorsArray
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
        
        struct Complex : Equatable {
            let real: Float64!
            let imaginary: Float64!
        }
    }
}

extension Fits {  // Based off https://stackoverflow.com/a/30958731/1191087
    static func imageFromRGBA32Data(data: [UInt8], width: Int, height: Int) -> NSImage? {
        guard width > 0 && height > 0 else { return nil }
        guard data.count == width * height * 4 else { return nil }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        var mutableData = data // Copy to mutable []
        guard let providerRef = CGDataProvider(data: NSData(bytes: &mutableData, length: mutableData.count * MemoryLayout<UInt8>.size)
            )
            else { return nil }
        
        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<UInt8>.size * 4,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
            )
            else { return nil }
        
        return NSImage(cgImage: cgImage, size: NSZeroSize)
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

