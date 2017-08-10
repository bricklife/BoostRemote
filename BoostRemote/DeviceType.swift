//
//  DeviceType.swift
//  BoostRemote
//
//  Created by ooba on 10/08/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation

enum DeviceType: UInt8 {
    
    case colorDistanceSensor    = 0x25
    case interactiveMotor       = 0x26
    case builtInMotor           = 0x27
}

extension DeviceType: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .colorDistanceSensor:
            return "Color & Distance Sensor"
        case .interactiveMotor:
            return "Interactive Motor"
        case .builtInMotor:
            return "Built-in Motor"
        }
    }
}
