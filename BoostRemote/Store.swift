//
//  Store.swift
//  BoostRemote
//
//  Created by ooba on 21/09/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift
import BoostBLEKit

struct StoreCenter {
    
    static let store: Store<State> = {
        let state = PersistentManager.shared.load()
        let store = Store<State>(reducer: Reducer.appReducer, state: state)
        store.subscribe(PersistentManager.shared)
        
        return store
    }()
    
    final class PersistentManager: StoreSubscriber {
        
        static let shared = PersistentManager()
        
        private let allPorts: [BoostBLEKit.Port] = [.A, .B, .C, .D]
        
        func newState(state: State) {
            save(state: state)
        }
        
        func load() -> State {
            var settingsState = SettingsState()
            
            if let rawValue = UserDefaults.standard.string(forKey: "mode"), let mode = SettingsState.Mode(rawValue: rawValue) {
                settingsState.mode = mode
            }
            
            if let step = UserDefaults.standard.object(forKey: "step") as? SettingsState.Step {
                settingsState.step = step
            }
            
            for port in allPorts {
                let key = "direction-\(port)"
                if let direction = UserDefaults.standard.object(forKey: key) as? Bool {
                    settingsState.directions[port] = direction
                }
            }
            
            return State(connectionState: .disconnected,
                         portState: [:],
                         settingsState: settingsState)
        }
        
        func save(state: State) {
            UserDefaults.standard.set(state.settingsState.mode.rawValue, forKey: "mode")
            UserDefaults.standard.set(state.settingsState.step, forKey: "step")
            for (port, direction) in state.settingsState.directions {
                let key = "direction-\(port)"
                UserDefaults.standard.set(direction, forKey: key)
            }
        }
    }
}
