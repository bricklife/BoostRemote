//
//  Data+HexString.swift
//  BoostRemote
//
//  Created by ooba on 10/08/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation

extension Data {
    
    public init?(hexString: String) {
        var hexString = hexString
            .replacingOccurrences(of: "0x", with: "")
            .components(separatedBy: CharacterSet(charactersIn: "0123456789abcdefABCDEF").inverted)
            .joined()
        
        guard hexString.characters.count % 2 == 0 else { return nil }
        
        var data = Data(capacity: hexString.characters.count / 2)
        
        while (hexString.characters.count > 0) {
            let index = hexString.index(hexString.startIndex, offsetBy: 2)
            let byteLiteral = hexString.substring(to: index)
            guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
            data.append(byte)
            hexString = hexString.substring(from: index)
        }
        
        self = data
    }
    
    public var hexString: String {
        return map { String(format: "%02x", $0) }.joined(separator: " ")
    }
}
