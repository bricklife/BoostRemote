//
//  Reducer.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/07.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift

struct Reducer {
    
    static func appReducer(action: Action, state: State?) -> State {
        return State(
            connectionState: connectionReducer(state: state?.connectionState, action: action),
            portState: portReducer(state: state?.portState, action: action),
            settingsState: settingsReducer(state: state?.settingsState, action: action)
        )
    }
    
    static func connectionReducer(state: ConnectionState?, action: Action) -> ConnectionState {
        let state = state ?? .disconnected
        
        guard let action = action as? ConnectAction else { return state }
        
        switch action {
        case .scan:
            return .connecting
        case .connect:
            return state == .connecting ? .connected : state
        case .disconnect:
            return .disconnected
        case .offline:
            return .offline
        case .unsupported:
            return .unsupported
        }
    }
    
    static func portReducer(state: PortState?, action: Action) -> PortState {
        var state = state ?? [:]
        
        guard let action = action as? NotificationAction else { return state }
        
        switch action.notification {
        case .connected(let port, let deviceType):
            state[port] = deviceType
        case .disconnected(let port):
            state[port] = nil
        }
        
        return state
    }
    
    static func settingsReducer(state: SettingsState?, action: Action) -> SettingsState {
        var state = state ?? SettingsState()
        
        guard let action = action as? SettingsAction else { return state }
        
        switch action {
        case .step(let step):
            state.step = step
            if state.step < 1 {
                state.step = 1
            }
            if state.step > 100 {
                state.step = 100
            }
            
        case .mode(let mode):
            state.mode = mode
        }
        
        return state
    }
}
