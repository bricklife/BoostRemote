//
//  Controller.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2018/01/26.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import Foundation
import ReactiveSwift
import BoostBLEKit

protocol Controller {
    
    var signals: [BoostBLEKit.Port: Signal<Double, Never>] { get }
    
    func setEnable(_ enable: Bool, port: BoostBLEKit.Port)
}
