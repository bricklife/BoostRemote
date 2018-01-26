//
//  ControllerViewController.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2017/08/01.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReSwift
import BoostBLEKit

class ControllerViewController: UIViewController {
    
    @IBOutlet private weak var connectButtonImageView: UIImageView!
    
    private var stickViewController: FourSticksViewController? {
        return childViewControllers.first as? FourSticksViewController
    }
    
    private let connectionState = MutableProperty(ConnectionState.disconnected)
    
    private var motors: [BoostBLEKit.Port: Motor] = [:] {
        didSet {
            stickViewController?.setEnable(motors.keys.contains(.C), port: .C)
            stickViewController?.setEnable(motors.keys.contains(.D), port: .D)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConnectButtonImageView()
        setupSticks()
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
        connectButtonImageView.animationImages = UIImage.connectingImages()
        
        connectionState.producer.startWithValues { [weak self] (state) in
            if state == .connecting {
                self?.connectButtonImageView.startAnimating()
            } else {
                self?.connectButtonImageView.stopAnimating()
            }
            self?.connectButtonImageView.image = UIImage(connectionState: state)
        }
    }
    
    private func setupSticks() {
        stickViewController?.signals.forEach { (port, signal) in
            signal.map { Int8($0 * 10) * 10 }
                .skipRepeats()
                .observeValues { [weak self] (value) in
                    self?.sendCommand(port: port, power: value)
            }
        }
    }
    
    private func sendCommand(port: BoostBLEKit.Port, power: Int8) {
        if power == 100 || power == -100 {
            FeedbackGenerator.feedback()
        }
        
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
        
        let ports: [BoostBLEKit.Port] = [.A, .B, .C, .D]
        for port in ports {
            motors[port] = state.portState[port].flatMap { type -> Motor? in
                guard state.connectionState == .connected else { return nil }
                return Motor(port: port, deviceType: type)
            }
        }
    }
}
