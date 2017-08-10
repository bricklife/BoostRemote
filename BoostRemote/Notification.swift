//
//  Notification.swift
//  BoostRemote
//
//  Created by ooba on 10/08/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation

enum Notification {
    
    case connected(Port, DeviceType)
    case disconnected(Port)
}

extension Notification {
    
    init?(data: Data) {
        guard data.count >= 3 else { return nil }
        
        switch data[2] {
        case 0x04:
            guard data.count >= 5 else { return nil }
            guard let port = Port(rawValue: data[3]) else { return nil }
            
            switch data[4] {
            case 0x00:
                self = .disconnected(port)
            case 0x01, 0x02:
                guard data.count >= 6 else { return nil }
                guard let deviceType = DeviceType(rawValue: data[5]) else { return nil }
                self = .connected(port, deviceType)
            default:
                return nil
            }
            
        default:
            return nil
        }
    }
}

extension Notification: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .connected(let port, let deviceType):
            return "Connected \(deviceType) into \(port)"
        case .disconnected(let port):
            return "Disconnected a device from \(port)"
        }
    }
}
