//
//  StickView.swift
//  BoostRemote
//
//  Created by ooba on 09/10/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit

@IBDesignable
class StickView: UIView {
    
    private let verticalSlider = VerticalSlider()
    private let label = UILabel()
    
    var slider: UISlider {
        return verticalSlider.slider
    }
    
    @IBInspectable var text: String? {
        didSet {
            label.text = text
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    private func initialize() {
        setupSlider()
        setupLabel()
        
        verticalSlider.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(verticalSlider)
        addSubview(label)
        
        NSLayoutConstraint.activate([
            verticalSlider.topAnchor.constraint(equalTo: topAnchor),
            verticalSlider.leftAnchor.constraint(equalTo: leftAnchor),
            verticalSlider.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: verticalSlider.bottomAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 30),
            ])
    }
    
    private func setupSlider() {
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "left"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "right"), for: .normal)
        
        slider.maximumValue = 10
        slider.minimumValue = -10
        slider.value = 0
    }
    
    private func setupLabel() {
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .black
    }
}
