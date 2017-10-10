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

class ControllerViewController: UIViewController {
    
    @IBOutlet private weak var leftStick: StickView!
    @IBOutlet private weak var rightStick: StickView!
    @IBOutlet private weak var centerStick: StickView!
    
    @IBOutlet private weak var connectButtonImageView: UIImageView!
    
    private let connectionState = MutableProperty(ConnectionState.disconnected)
    
    private var leftMotor: Motor? = Motor(port: .A)
    private var rightMotor: Motor? = Motor(port: .B)
    private var centerMotor: Motor? {
        didSet {
            let alpha: CGFloat
            if let motor = centerMotor {
                centerStick.text = motor.port.description
                alpha = 1.0
            } else {
                alpha = 0.0
            }
            
            UIView.animate(withDuration: 0.2) {
                self.centerStick.alpha = alpha
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerStick.alpha = 0.0

        setupConnectButtonImageView()
        
        signal(for: leftStick.slider).observeValues { [weak self] (value) in
            self?.sendCommand(motor: self?.leftMotor, power: value)
        }
        signal(for: rightStick.slider).observeValues { [weak self] (value) in
            self?.sendCommand(motor: self?.rightMotor, power: value)
        }
        signal(for: centerStick.slider).observeValues { [weak self] (value) in
            self?.sendCommand(motor: self?.centerMotor, power: value)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StoreCenter.store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        StoreCenter.store.unsubscribe(self)
    }
    
    private func setupConnectButtonImageView() {
        connectButtonImageView.animationDuration = 1
        connectButtonImageView.animationRepeatCount = -1
        connectButtonImageView.animationImages = (1...4).map { "connecting\($0)" }.flatMap { UIImage(named: $0) }
        
        connectionState.producer.startWithValues { [weak self] (state) in
            if state == .connecting {
                self?.connectButtonImageView.startAnimating()
            } else {
                self?.connectButtonImageView.stopAnimating()
            }
            
            let imageName: String
            switch state {
            case .disconnected:
                imageName = "disconnected"
            case .connecting:
                imageName = "disconnected"
            case .connected:
                imageName = "connected"
            case .offline, .unsupported:
                imageName = "offline"
            }
            self?.connectButtonImageView.image = UIImage(named: imageName)
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
    
    private func alert(message: String) {
        let alert = UIAlertController(title: "CAUTION", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func connectButtonPushed(_ sender: Any) {
        switch connectionState.value {
        case .disconnected:
            ActionCenter.startScan()
        case .connected:
            ActionCenter.disconnect()
        case .connecting:
            ActionCenter.stopScan()
        case .offline:
            alert(message: "Turn on Bluetooth")
        case .unsupported:
            alert(message: "Unsupported Device")
        }
    }
}

extension ControllerViewController: StoreSubscriber {
    
    func newState(state: State) {
        connectionState.value = state.connectionState
        
        if state.connectionState == .connected {
            centerMotor = state.portState
                .flatMap { (port, type) -> Motor? in
                    return type == .interactiveMotor ? Motor(port: port) : nil
                }
                .first
        } else {
            centerMotor = nil
        }
    }
}
