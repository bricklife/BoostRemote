//
//  JoystickView.swift
//  BoostRemote
//
//  Created by ooba on 26/01/2018.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit

class JoystickView: UIView {
    
    private(set) var x: Double = 0
    private(set) var y: Double = 0
    
    var update: ((Double, Double) -> Void)?
    
    private var thumbCenterXConstraint: NSLayoutConstraint!
    private var thumbCenterYConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(baseView)
        addSubview(thumbView)
        
        NSLayoutConstraint.activate([
            baseView.widthAnchor.constraint(equalTo: widthAnchor),
            baseView.heightAnchor.constraint(equalTo: heightAnchor),
            baseView.centerXAnchor.constraint(equalTo: centerXAnchor),
            baseView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        
        thumbCenterXConstraint = thumbView.centerXAnchor.constraint(equalTo: centerXAnchor)
        thumbCenterYConstraint = thumbView.centerYAnchor.constraint(equalTo: centerYAnchor)

        NSLayoutConstraint.activate([
            thumbView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            thumbView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            thumbCenterXConstraint,
            thumbCenterYConstraint,
            ])
    }
    
    private let baseView: UIView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "base"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let thumbView: UIView = {
        let view = UIImageView(image: #imageLiteral(resourceName: "thumb"))
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private func move(location: CGPoint) {
        let width = (bounds.width - thumbView.bounds.width) / 2
        let height = (bounds.height - thumbView.bounds.height) / 2
        
        var x = (location.x - bounds.midX) / width
        if x < -1 {
            x = -1
        } else if x > 1 {
            x = 1
        }
        
        var y = (location.y - bounds.midY) / height
        if y < -1 {
            y = -1
        } else if y > 1 {
            y = 1
        }
        
        thumbCenterXConstraint.constant = x * width
        thumbCenterYConstraint.constant = y * height
        
        let newX = Double(x)
        let newY = Double(y)
        
        if (newX == 1 || newX == -1) && self.x != newX {
            FeedbackGenerator.feedback()
        }
        if (newY == 1 || newY == -1) && self.y != newY {
            FeedbackGenerator.feedback()
        }
        
        self.x = newX
        self.y = newY
        
        update?(newX, newY)
    }
    
    private func reset() {
        move(location: CGPoint(x: bounds.midX, y: bounds.midY))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        move(location: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        move(location: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
}
