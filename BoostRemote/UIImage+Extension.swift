//
//  UIImage+Extension.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2018/01/26.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit
import BoostBLEKit

extension UIImage {
    
    convenience init?(port: BoostBLEKit.Port) {
        self.init(named: "port\(port)")
    }
    
    convenience init?(connectionState: ConnectionState) {
        let imageName: String
        switch connectionState {
        case .disconnected:
            imageName = "disconnected"
        case .connecting:
            imageName = "disconnected"
        case .connected:
            imageName = "connected"
        case .offline, .unsupported:
            imageName = "offline"
        }
        self.init(named: imageName)
    }
    
    static func connectingImages() -> [UIImage] {
        return (1...4).map { "connecting\($0)" }.flatMap(UIImage.init(named:))
    }
}
