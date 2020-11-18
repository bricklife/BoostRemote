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
    case connected(Hub)
    case connecting
    case offline
    case unauthorized
    case unsupported
}

typealias PortState = [PortId: IOType]

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
    var directions: [BoostBLEKit.Port: Bool]

    init() {
        self.mode = .joystick
        self.step = 5
        self.directions = [.A: true, .B: true, .C: true, .D: true]
    }
}
