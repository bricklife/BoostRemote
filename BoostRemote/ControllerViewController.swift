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
import ReSwift

class ControllerViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var leftSlider: UISlider!
    @IBOutlet weak var rightSlider: UISlider!
    @IBOutlet weak var centerSlider: UISlider!
    @IBOutlet weak var connectButton: UIButton!
    
    let connectionState = MutableProperty(ConnectionState.disconnected)
    
    var leftMotor: Motor? = Motor(port: .A)
    var rightMotor: Motor? = Motor(port: .B)
    var centerMotor: Motor? = Motor(port: .C)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp(slider: leftSlider)
        setUp(slider: rightSlider)
        setUp(slider: centerSlider)
        
        setUp(button: connectButton)
        
        signal(for: leftSlider).observeValues { [weak self] (value) in
            self?.sendCommand(motor: self?.leftMotor, power: value)
        }
        signal(for: rightSlider).observeValues { [weak self] (value) in
            self?.sendCommand(motor: self?.rightMotor, power: value)
        }
        signal(for: centerSlider).observeValues { [weak self] (value) in
            self?.sendCommand(motor: self?.centerMotor, power: value)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    func newState(state: State) {
        connectionState.value = state.connectionState
    }
    
    private func setUp(slider: UISlider) {
        slider.setThumbImage(UIImage(named: "thumb")?.withRenderingMode(.alwaysTemplate), for: .normal)
        slider.setMinimumTrackImage(UIImage(named: "left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -0.5))
        
        //slider.reactive.isEnabled <~ connectionState.map { $0 == .connected }
    }
    
    private func setUp(button: UIButton) {
        connectionState.producer.startWithValues { [weak self] (state) in
            let imageName: String
            let alpha: CGFloat
            
            switch state {
            case .disconnected:
                imageName = "disconnected"
                alpha = 1
            case .connecting:
                imageName = "connected"
                alpha = 0.5
            case .connected:
                imageName = "connected"
                alpha = 1
            }
            
            self?.connectButton.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
            self?.connectButton.alpha = alpha
        }
    }

    private func signal(for slider: UISlider) -> Signal<Int8, NoError> {
        let valueSignal = slider.reactive.values.map { Int8($0) * 10 }
        
        let touchUpSignal = Signal<UISlider, NoError>
            .merge(slider.reactive.controlEvents(.touchUpInside),
                   slider.reactive.controlEvents(.touchUpOutside))
            .on(value: { $0.value = 0 })
            .map { _ in Int8(0) }
        
        return Signal<Int8, NoError>.merge(valueSignal, touchUpSignal).skipRepeats()
    }
    
    private func sendCommand(motor: Motor?, power: Int8) {
        if let command = motor?.powerCommand(power: power) {
            ActionCenter.send(command: command)
        }
    }
    
    @IBAction func connectButtonPushed(_ sender: Any) {
        switch connectionState.value {
        case .disconnected:
            ActionCenter.startScan()
        case .connecting, .connected:
            ActionCenter.disconnect()
        }
    }
}
