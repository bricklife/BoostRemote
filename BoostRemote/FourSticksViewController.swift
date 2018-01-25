//
//  FourSticksViewController.swift
//  BoostRemote
//
//  Created by ooba on 25/01/2018.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import BoostBLEKit

class FourSticksViewController: UIViewController {
    
    @IBOutlet private weak var stickA: StickView!
    @IBOutlet private weak var stickB: StickView!
    @IBOutlet private weak var stickC: StickView!
    @IBOutlet private weak var stickD: StickView!
    
    var motors: [BoostBLEKit.Port: Motor] = [:] {
        didSet {
            stickC?.isHidden = !motors.keys.contains(.C)
            stickD?.isHidden = !motors.keys.contains(.D)
        }
    }
    
    private let (signalA, observerA) = Signal<CGFloat, NoError>.pipe()
    private let (signalB, observerB) = Signal<CGFloat, NoError>.pipe()
    private let (signalC, observerC) = Signal<CGFloat, NoError>.pipe()
    private let (signalD, observerD) = Signal<CGFloat, NoError>.pipe()
    
    lazy var signal: [BoostBLEKit.Port: Signal<CGFloat, NoError>] = [
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
        
        stickC.isHidden = true
        stickD.isHidden = true
    }
}
