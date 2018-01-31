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
    case connect
    case disconnect
    case offline
    case unsupported
}

struct NotificationAction: Action {
    
    let notification: BoostBLEKit.Notification
}

enum SettingsAction: Action {
    
    case step(SettingsState.Step)
    case mode(SettingsState.Mode)
}

struct ActionCenter {
    
    static func startScan() {
        let action: Store<State>.ActionCreator = { state, store in
            MoveHubManager.shared.startScan()
            return ConnectAction.scan
        }
        StoreCenter.store.dispatch(action)
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
