//
//  MoveHubService.swift
//  BoostRemote
//
//  Created by ooba on 10/08/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import CoreBluetooth

struct MoveHubService {
    
    static let serviceUuid = CBUUID(string: "00001623-1212-EFDE-1623-785FEABCD123")
    static let characteristicUuid = CBUUID(string: "00001624-1212-EFDE-1623-785FEABCD123")
}
