//
//  TwinSticksViewController.swift
//  BoostRemote
//
//  Created by ooba on 25/01/2018.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveSwift
import BoostBLEKit

class TwinSticksViewController: UIViewController, Controller {
    
    @IBOutlet private weak var stickA: StickView!
    @IBOutlet private weak var stickB: StickView!
    @IBOutlet private weak var stickC: StickView!
    @IBOutlet private weak var stickD: StickView!
    
    private let (signalA, observerA) = Signal<Double, Never>.pipe()
    private let (signalB, observerB) = Signal<Double, Never>.pipe()
    private let (signalC, observerC) = Signal<Double, Never>.pipe()
    private let (signalD, observerD) = Signal<Double, Never>.pipe()
    
    lazy var signals: [BoostBLEKit.Port: Signal<Double, Never>] = [
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
        stickA.port = .A
        stickB.port = .B
        stickC.port = .C
        stickD.port = .D
        
        stickA.signal.observe(observerA)
        stickB.signal.observe(observerB)
        stickC.signal.observe(observerC)
        stickD.signal.observe(observerD)
    }
    
    func setEnable(_ enable: Bool, port: BoostBLEKit.Port) {
        switch port {
        case .A:
            stickA.isEnabled = enable
        case .B:
            stickB.isEnabled = enable
        case .C:
            stickC.isEnabled = enable
        case .D:
            stickD.isEnabled = enable
        default:
            break
        }
    }
}
