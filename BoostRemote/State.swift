//
//  State.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/07.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift
import BoostBLEKit

struct State: StateType {
    
    var connectionState: ConnectionState
    var portState: PortState
    var settingsState: SettingsState
}

enum ConnectionState {
    
    case disconnected
    case connected
    case connecting
    case offline
    case unsupported
}

typealias PortState = [BoostBLEKit.Port: DeviceType]

struct SettingsState {
    
    var mode: Settings.Mode
    var step: Settings.Step
}
