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
    
    @IBOutlet private weak var stickC: StickView!
    @IBOutlet private weak var stickD: StickView!
    
    private let (signalA, observerA) = Signal<Double, NoError>.pipe()
    private let (signalB, observerB) = Signal<Double, NoError>.pipe()
    private let (signalC, observerC) = Signal<Double, NoError>.pipe()
    private let (signalD, observerD) = Signal<Double, NoError>.pipe()
    
    lazy var signals: [BoostBLEKit.Port: Signal<Double, NoError>] = [
        .A: self.signalA,
        .B: self.signalB,
        .C: self.signalC,
        .D: self.signalD,
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSticks()
    }
    
    private func setupSticks() {
        stickC.port = .C
        stickD.port = .D
        
        stickC.signal.observe(observerC)
        stickD.signal.observe(observerD)
    }
    
    func setEnable(_ enable: Bool, port: BoostBLEKit.Port) {
        switch port {
        case .C:
            stickC.isHidden = !enable
        case .D:
            stickD.isHidden = !enable
        default:
            break
        }
    }
}
