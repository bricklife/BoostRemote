//
//  UIColor+Extension.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2019/11/01.
//  Copyright © 2019 bricklife.com. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
        }
        return light
    }
}

extension UIColor {
    
    static var tint: UIColor {
        return dynamicColor(
            light: UIColor(hex: 0x353839),
            dark: .lightGray
        )
    }
    
    static var background: UIColor {
        return dynamicColor(
            light: .white,
            dark: .black
        )
    }
}
