//
//  Store.swift
//  BoostRemote
//
//  Created by ooba on 21/09/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import ReSwift

struct StoreCenter {
    
    static let store = Store<State>(reducer: Reducer.appReducer, state: nil)
}
