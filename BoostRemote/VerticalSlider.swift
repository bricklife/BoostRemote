//
//  VerticalSlider.swift
//  BoostRemote
//
//  Created by ooba on 09/10/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit

class VerticalSlider: UIView {
    
    private(set) var value: Double = 0
    
    var update: ((Double) -> Void)?
    
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
            baseView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            baseView.heightAnchor.constraint(equalTo: heightAnchor),
            baseView.centerXAnchor.constraint(equalTo: centerXAnchor),
            baseView.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        
        thumbCenterYConstraint = thumbView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            thumbView.centerXAnchor.constraint(equalTo: centerXAnchor),
            thumbView.widthAnchor.constraint(equalTo: widthAnchor),
            thumbView.heightAnchor.constraint(equalTo: widthAnchor),
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
        let size = thumbView.bounds.height
        let base = (bounds.height - size) / 2
        
        var value = (location.y - bounds.midY) / base
        if value < -1 {
            value = -1
        } else if value > 1 {
            value = 1
        }
        
        thumbCenterYConstraint.constant = base * value
        
        let newValue = Double(value)
        
        if (newValue == 1 || newValue == -1) && self.value != newValue {
            FeedbackGenerator.feedback()
        }
        
        self.value = newValue
        
        update?(newValue)
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
