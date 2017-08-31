//
//  Action.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/07.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift

enum ConnectAction: Action {
    
    case scan
    case connect
    case disconnect
    case offline
    case unsupported
}

struct NotificationAction: Action {
    
    let notification: Notification
}

struct ActionCenter {
    
    static func startScan() {
        let action: Store<State>.ActionCreator = { state, store in
            MoveHubManager.shared.startScan()
            return ConnectAction.scan
        }
        store.dispatch(action)
    }
    
    static func stopScan() {
        MoveHubManager.shared.stopScan()
        store.dispatch(ConnectAction.disconnect)
    }
    
    static func disconnect() {
        MoveHubManager.shared.disconnect()
        store.dispatch(ConnectAction.disconnect)
    }
    
    static func send(command: Command) {
        print(command)
        MoveHubManager.shared.write(data: command.data)
    }
}
