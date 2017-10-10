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
        addSubview(verticalSlider)
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            verticalSlider.topAnchor.constraint(equalTo: topAnchor),
            verticalSlider.leftAnchor.constraint(equalTo: leftAnchor),
            verticalSlider.rightAnchor.constraint(equalTo: rightAnchor),
            ])
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: verticalSlider.bottomAnchor, constant: 16),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            ])
    }
    
    private let verticalSlider: VerticalSlider = {
        let verticalSlider = VerticalSlider()
        verticalSlider.translatesAutoresizingMaskIntoConstraints = false
        
        verticalSlider.slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        verticalSlider.slider.setMinimumTrackImage(UIImage(named: "left"), for: .normal)
        verticalSlider.slider.setMaximumTrackImage(UIImage(named: "right"), for: .normal)
        
        verticalSlider.slider.maximumValue = 10
        verticalSlider.slider.minimumValue = -10
        verticalSlider.slider.value = 0
        
        return verticalSlider
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .center
        return imageView
    }()
}
