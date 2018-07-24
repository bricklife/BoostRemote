//
//  JoystickViewController.swift
//  BoostRemote
//
//  Created by ooba on 26/01/2018.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import BoostBLEKit

class JoystickViewController: UIViewController, Controller {
    
    @IBOutlet private weak var joystickView: JoystickView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var stickC: StickView!
    @IBOutlet private weak var stickD: StickView!
    
    private let (signalA, observerA) = Signal<Double, NoError>.pipe()
    private let (signalB, observerB) = Signal<Double, NoError>.pipe()
    private let (signalC, observerC) = Signal<Double, NoError>.pipe()
    private let (signalD, observerD) = Signal<Double, NoError>.pipe()
    
    private var isEnableA: Bool = true
    private var isEnableB: Bool = true
    
    lazy var signals: [BoostBLEKit.Port: Signal<Double, NoError>] = [
        .A: self.signalA,
        .B: self.signalB,
        .C: self.signalC,
        .D: self.signalD,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupJoystick()
        setupSticks()
    }
    
    private func setupJoystick() {
        joystickView.update = { [weak self] (x, y) in
            func calc(x: Double, y: Double) -> Double {
                if x > 0, y > 0 {
                    return max(x, y)
                } else if x < 0, y < 0 {
                    return min(x, y)
                } else {
                    return x + y
                }
            }
            let valueA = calc(x: x, y: -y)
            let valueB = calc(x: -x, y: -y)
            
            self?.observerA.send(value: valueA)
            self?.observerB.send(value: valueB)
        }
    }
    
    private func setupSticks() {
        stickC.port = .C
        stickD.port = .D
        
        stickC.signal.observe(observerC)
        stickD.signal.observe(observerD)
    }
    
    func setEnable(_ enable: Bool, port: BoostBLEKit.Port) {
        switch port {
        case .A:
            isEnableA = enable
        case .B:
            isEnableB = enable
        case .C:
            stickC.isEnabled = enable
        case .D:
            stickD.isEnabled = enable
        default:
            break
        }
        
        imageView.alpha = isEnableA && isEnableB ? 1.0 : 0.25
    }
}
