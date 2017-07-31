//
//  ControllerViewController.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/01.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class ControllerViewController: UIViewController {
    
    @IBOutlet weak var leftSlider: UISlider!
    @IBOutlet weak var rightSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(slider: leftSlider)
        setUp(slider: rightSlider)
        
        signal(for: leftSlider).observeValues { (value) in
            print("left:", value)
        }
        signal(for: rightSlider).observeValues { (value) in
            print("right:", value)
        }
    }
    
    private func setUp(slider: UISlider) {
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "left"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "right"), for: .normal)
        
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -0.5))
    }
    
    private func signal(for slider: UISlider) -> Signal<Int, NoError> {
        let valueSignal = slider.reactive.values.map { Int($0) }
        
        let touchUpSignal = Signal<UISlider, NoError>
            .merge(slider.reactive.controlEvents(.touchUpInside),
                   slider.reactive.controlEvents(.touchUpOutside))
            .on(value: { $0.value = 0 })
            .map { _ in 0 }
        
        return Signal<Int, NoError>.merge(valueSignal, touchUpSignal).skipRepeats()
    }
}
