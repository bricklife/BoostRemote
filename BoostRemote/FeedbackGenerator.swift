//
//  FeedbackGenerator.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2018/01/25.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit

final class FeedbackGenerator {
    
    private static let feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    static func feedback() {
        if #available(iOS 10.0, *) {
            (feedbackGenerator as? UIImpactFeedbackGenerator)?.impactOccurred()
        }
    }
}
