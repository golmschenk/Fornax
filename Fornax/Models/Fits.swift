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
        bytes = Array(buffer.prefix(upTo: 80))
        let string = String(bytes: bytes, encoding: .ascii)!
        header.append(string)
    }
}
