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
    
    @IBOutlet private weak var stickA: StickView!
    @IBOutlet private weak var stickB: StickView!
    @IBOutlet private weak var stickC: StickView!
    @IBOutlet private weak var stickD: StickView!
    
    @IBOutlet private weak var connectButtonImageView: UIImageView!
    
    private let connectionState = MutableProperty(ConnectionState.disconnected)
    
    private var motors: [Port: Motor] = [:] {
        didSet {
            stickC?.isHidden = !motors.keys.contains(.C)
            stickD?.isHidden = !motors.keys.contains(.D)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConnectButtonImageView()
        
        stickA.port = .A
        stickB.port = .B
        stickC.port = .C
        stickD.port = .D
        
        stickC.isHidden = true
        stickD.isHidden = true
        
        signal(for: stickA.slider).observeValues { [weak self] (value) in
            self?.sendCommand(port: .A, power: value)
        }
        signal(for: stickB.slider).observeValues { [weak self] (value) in
            self?.sendCommand(port: .B, power: value)
        }
        signal(for: stickC.slider).observeValues { [weak self] (value) in
            self?.sendCommand(port: .C, power: value)
        }
        signal(for: stickD.slider).observeValues { [weak self] (value) in
            self?.sendCommand(port: .D, power: value)
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
    
    private func sendCommand(port: Port, power: Int8) {
        if let command = motors[port]?.powerCommand(power: power) {
            ActionCenter.send(command: command)
        }
    }
    
    private func alert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("CAUTION", comment: "CAUTION"), message: message, preferredStyle: .alert)
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
            alert(message: NSLocalizedString("Turn on Bluetooth", comment: "Turn on Bluetooth"))
        case .unsupported:
            alert(message: NSLocalizedString("Unsupported Device", comment: "Unsupported Device"))
        }
    }
}

extension ControllerViewController: StoreSubscriber {
    
    func newState(state: State) {
        connectionState.value = state.connectionState
        
        let ports: [Port] = [.A, .B, .C, .D]
        for port in ports {
            motors[port] = state.portState[port].flatMap { type -> Motor? in
                guard state.connectionState == .connected else { return nil }
                switch type {
                case .builtInMotor, .interactiveMotor:
                    return Motor(port: port)
                default:
                    return nil
                }
            }
        }
    }
}
