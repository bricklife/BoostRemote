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
}

struct ActionCenter {
    
    static func startScan() {
        let action: Store<State>.ActionCreator = { state, store in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                store.dispatch(ConnectAction.connect)
            }
            return ConnectAction.scan
        }
        store.dispatch(action)
    }
    
    static func disconnect() {
        store.dispatch(ConnectAction.disconnect)
    }
    
    static func send(command: Command) {
        print(command)
        print(command.data as NSData)
    }
}
