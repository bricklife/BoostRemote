//
//  Motor.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/08.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation

struct Motor {
    
    let port: Port
    
    func powerCommand(power: Int8) -> MotorPowerCommand {
        return MotorPowerCommand(port: port, power: power)
    }
}
