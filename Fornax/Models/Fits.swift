//
//  Fits.swift
//  Fornax
//
//  Created by Greg Olmschenk on 12/2/18.
//  Copyright © 2018 Greg Olmschenk. All rights reserved.
//

import Foundation

class Fits {
    
    var header = [String]()
    
    init(fromPath filePath: String) {
        var bytes = [UInt8]()
        let data = NSData(contentsOfFile: filePath)!
        var buffer = [UInt8](repeating: 0, count: data.length)
        data.getBytes(&buffer, length: data.length)
        var headerCount = 0
        while true {
            bytes = Array(buffer[headerCount * 80 ..< (headerCount + 1) * 80])
            let string = String(bytes: bytes, encoding: .ascii)!
            if string.prefix(3) == "END" {
                break
            }
            else {
                header.append(string)
                headerCount += 1
            }
        }
    }
}
