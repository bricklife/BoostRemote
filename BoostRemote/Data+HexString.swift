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
        let hexString = hexString
            .replacingOccurrences(of: "0x", with: "")
            .components(separatedBy: CharacterSet(charactersIn: "0123456789abcdefABCDEF").inverted)
            .joined()
        
        let even = hexString.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element }
        let odd  = hexString.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element }
        
        let bytes = zip(even, odd).compactMap { UInt8(String([$0.0, $0.1]), radix: 16) }
        
        self.init(bytes)
    }
    
    public var hexString: String {
        return map { String(format: "%02x", $0) }.joined(separator: " ")
    }
}
