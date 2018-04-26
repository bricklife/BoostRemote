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
    var step: Step {
        didSet {
            if step < 1 {
                step = 1
            }
            if step > 100 {
                step = 100
            }
        }
    }
    
    init() {
        self.mode = .joystick
        self.step = 5
    }
}
