//
//  Settings.swift
//  BoostRemote
//
//  Created by ooba on 26/01/2018.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import Foundation

final class Settings {
    
    private static var userDefaults: UserDefaults = {
        UserDefaults.standard.register(defaults: ["step": Double(5)])
        return UserDefaults.standard
    }()
    
    static var step: Double {
        get { return userDefaults.double(forKey: "step") }
        set { userDefaults.set(newValue, forKey: "step") }
    }
    
    enum Mode: String {
        case joystick = "joystick"
        case twinsticks = "twinsticks"
    }
    
    static var mode: Mode {
        get { return userDefaults.string(forKey: "mode").flatMap(Mode.init(rawValue:)) ?? .joystick }
        set { userDefaults.set(newValue.rawValue, forKey: "mode") }
    }
}
