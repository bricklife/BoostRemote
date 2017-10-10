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
    private let imageView = UIImageView()
    
    var slider: UISlider {
        return verticalSlider.slider
    }
    
    var port: Port? {
        didSet {
            imageView.image = port.flatMap { UIImage(named: "port\($0)") }
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
        
        verticalSlider.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(verticalSlider)
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            verticalSlider.topAnchor.constraint(equalTo: topAnchor),
            verticalSlider.leftAnchor.constraint(equalTo: leftAnchor),
            verticalSlider.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: verticalSlider.bottomAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 24),
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
}
