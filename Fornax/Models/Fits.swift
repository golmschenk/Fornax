//
//  Fits.swift
//  Fornax
//
//  Created by Greg Olmschenk on 12/2/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import Foundation

class Fits {

    let headerCardLength = 80
    let recordLength = 2880

    var headerCards = [String]()
    
    init(fromUrl fileUrl: URL) {
        var bytes = [UInt8]()
        let data = try! Data(contentsOf: fileUrl)
        for headerCardStartIndex in stride(from: 0, to: data.count, by: headerCardLength)
        {
            bytes = Array(data[headerCardStartIndex ..< headerCardStartIndex + headerCardLength])
            let string = String(bytes: bytes, encoding: .ascii)!
            if string.prefix(3) == "END" {
                break
            }
            else {
                headerCards.append(string)
            }
        }
    }
}
