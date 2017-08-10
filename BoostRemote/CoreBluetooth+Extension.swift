//
//  CoreBluetooth+Extension.swift
//  BoostRemote
//
//  Created by ooba on 10/08/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCentralManagerState: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .poweredOff:
            return "poweredOff"
        case .poweredOn:
            return "poweredOn"
        case .resetting:
            return "resetting"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .unsupported:
            return "unsupported"
        }
    }
}
