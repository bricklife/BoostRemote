//
//  Command.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/08.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation

protocol Command: CustomStringConvertible {
    
    var data: Data { get }
}

struct MotorPowerCommand: Command {
    
    let port: Port
    let power: Int8
    
    var data: Data {
        let power = UInt8(bitPattern: self.power)
        return Data(bytes: [0x09, 0x00, 0x81, port.rawValue, 0x11, 0x07, power, 0x64, 0x03])
    }
    
    var description: String {
        return "MotorPowerCommand <port: \(port), power: \(power)>"
    }
}
