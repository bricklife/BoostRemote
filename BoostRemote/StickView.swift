//
//  StickView.swift
//  BoostRemote
//
//  Created by ooba on 09/10/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import BoostBLEKit

@IBDesignable
class StickView: UIView {
    
    var slider: UISlider {
        return verticalSlider.slider
    }
    
    var port: BoostBLEKit.Port? {
        didSet {
            imageView.image = port.flatMap { UIImage(named: "port\($0)") }
        }
    }
    
    lazy var signal: Signal<Float, NoError> = {
        let valueSignal = self.slider.reactive.values
        
        let touchUpSignal = Signal<UISlider, NoError>
            .merge(self.slider.reactive.controlEvents(.touchUpInside),
                   self.slider.reactive.controlEvents(.touchUpOutside))
            .on(value: { $0.value = 0 })
            .map { _ in Float(0) }
        
        return Signal<Float, NoError>.merge(valueSignal, touchUpSignal)
    }()
    
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
        
        verticalSlider.slider.maximumValue = 1
        verticalSlider.slider.minimumValue = -1
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
