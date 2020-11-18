//
//  Action.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/07.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift
import BoostBLEKit

enum ConnectAction: Action {
    
    case scan
    case connect(Hub)
    case disconnect
    case offline
    case unauthorized
    case unsupported
}

struct NotificationAction: Action {
    
    let notification: BoostBLEKit.Notification
}

enum SettingsAction: Action {
    
    case step(SettingsState.Step)
    case mode(SettingsState.Mode)
    case direction(BoostBLEKit.Port, Bool)
}

struct ActionCenter {
    
    static func startScan() {
        MoveHubManager.shared.startScan()
        StoreCenter.store.dispatch(ConnectAction.scan)
    }
    
    static func stopScan() {
        MoveHubManager.shared.stopScan()
        StoreCenter.store.dispatch(ConnectAction.disconnect)
    }
    
    static func disconnect() {
        MoveHubManager.shared.disconnect()
        StoreCenter.store.dispatch(ConnectAction.disconnect)
    }
    
    static func send(command: Command) {
        MoveHubManager.shared.write(data: command.data)
    }
}
