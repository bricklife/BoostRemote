//
//  Motor.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/08.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation

enum Port: UInt8 {
    
    case A  = 0x37
    case B  = 0x38
    case C  = 0x01
    case D  = 0x02
    case AB = 0x39
    
    var name: String {
        switch self {
        case .A:
            return "A"
        case .B:
            return "B"
        case .C:
            return "C"
        case .D:
            return "D"
        case .AB:
            return "A and B"
        }
    }
}

struct Motor {
    
    let port: Port
    
    func powerCommand(power: Int8) -> MotorPowerCommand {
        return MotorPowerCommand(port: port, power: power)
    }
}
