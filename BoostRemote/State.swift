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
    
    enum Mode: String {
        case joystick = "joystick"
        case twinsticks = "twinsticks"
    }
    
    typealias Step = Double
    
    var mode: Mode
    var step: Step
    
    init(mode: Mode = .joystick, step: Step = 5) {
        self.mode = mode
        self.step = step
    }
}
