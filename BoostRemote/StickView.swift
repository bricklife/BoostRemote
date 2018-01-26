//
//  StickView.swift
//  BoostRemote
//
//  Created by ooba on 09/10/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import BoostBLEKit

class StickView: UIView {
    
    let (signal, observer) = Signal<Double, NoError>.pipe()
    
    var port: BoostBLEKit.Port? {
        didSet {
            imageView.image = port.flatMap(UIImage.init(port:))
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
            imageView.leftAnchor.constraint(equalTo: leftAnchor),
            imageView.rightAnchor.constraint(equalTo: rightAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 32),
            ])
        
        verticalSlider.update = { [weak self] (value) in
            self?.observer.send(value: -value)
        }
    }
    
    private let verticalSlider: VerticalSlider = {
        let verticalSlider = VerticalSlider()
        verticalSlider.translatesAutoresizingMaskIntoConstraints = false
        
        return verticalSlider
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .center
        
        return imageView
    }()
}
