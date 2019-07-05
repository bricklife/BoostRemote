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
    @IBOutlet private weak var joystickView: UIView!
    @IBOutlet private weak var twinSticksView: UIView!
    
    let supportedPorts: [BoostBLEKit.Port] = [.A, .B, .C, .D]
    
    private var controllers: [Controller] {
        return children.compactMap { $0 as? Controller }
    }
    
    private let connectionState = MutableProperty(ConnectionState.disconnected)
    private let settingsState = MutableProperty<SettingsState>(SettingsState())
    
    private var connectedHub: Hub?
    private var connectedPorts: [BoostBLEKit.Port] = [] {
        didSet {
            for controller in controllers {
                for port in supportedPorts {
                    controller.setEnable(connectedPorts.contains(port), port: port)
                }
            }
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
            switch state {
            case .connecting:
                self?.connectButtonImageView.startAnimating()
            default:
                self?.connectButtonImageView.stopAnimating()
            }
            self?.connectButtonImageView.image = UIImage(connectionState: state)
        }
    }
    
    private func setupSticks() {
        for controller in controllers {
            for (port, signal) in controller.signals {
                signal
                    .withLatest(from: settingsState.signal.map { $0.step })
                    .map { (value: Double, step: Double) in Int8(round(value * step) * 100 / step) }
                    .skipRepeats()
                    .withLatest(from: settingsState.signal.map { $0.directions[port] ?? true })
                    .map { (power: Int8, direction: Bool) in direction ? power : -power }
                    .observeValues { [weak self] (value) in
                        self?.sendCommand(port: port, power: value)
                }
            }
        }
        
        settingsState.signal.observeValues { [weak self] (state) in
            self?.joystickView.isHidden = state.mode != .joystick
            self?.twinSticksView.isHidden = state.mode != .twinsticks
        }
    }
    
    private var timers: [BoostBLEKit.Port: Timer] = [:]
    private var waitingCommands: [BoostBLEKit.Port: Command] = [:]
    
    private func sendCommand(port: BoostBLEKit.Port, power: Int8) {
        guard let command = connectedHub?.motorStartPowerCommand(port: port, power: power) else { return }
        
        if timers[port] != nil {
            waitingCommands[port] = command
        } else {
            ActionCenter.send(command: command)
            timers[port] = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sendWaitingCommand), userInfo: port, repeats: false)
        }
    }
    
    @objc private func sendWaitingCommand(_ timer: Timer) {
        guard let port = timer.userInfo as? BoostBLEKit.Port else { return }
        timers[port] = nil
        
        guard let command = waitingCommands[port] else { return }
        waitingCommands[port] = nil
        
        ActionCenter.send(command: command)
    }
    
    private func alert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("CAUTION", comment: "CAUTION"), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(_ segue: UIStoryboardSegue) {}
    
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
        settingsState.value = state.settingsState
        
        switch state.connectionState {
        case .connected(let hub):
            connectedHub = hub
            connectedPorts = state.portState
                .filter { hub.canSupportAsMotor(ioType: $0.value) }
                .compactMap { hub.port(for: $0.key) }
                .filter { supportedPorts.contains($0) }
            
        default:
            connectedHub = nil
            connectedPorts = []
        }
    }
}
