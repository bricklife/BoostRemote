//
//  State.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/07.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift

struct State: StateType {
    
    var connectionState: ConnectionState
    var portState: PortState
}

enum ConnectionState {
    
    case disconnected
    case connected
    case connecting
}

typealias PortState = [Port: DeviceType]
