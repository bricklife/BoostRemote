//
//  VerticalSlider.swift
//  BoostRemote
//
//  Created by ooba on 09/10/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit

@IBDesignable
class VerticalSlider: UIView {
    
    let slider = UISlider()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(slider)
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -0.5))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        slider.bounds.size.width = bounds.height
        slider.center.x = bounds.midX
        slider.center.y = bounds.midY
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: slider.intrinsicContentSize.height, height: slider.intrinsicContentSize.width)
    }
}
