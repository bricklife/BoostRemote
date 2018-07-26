//
//  SettingsViewController.swift
//  BoostRemote
//
//  Created by Shinichiro Oba on 2018/01/30.
//  Copyright © 2018 bricklife.com. All rights reserved.
//

import UIKit
import ReSwift

class SettingsViewController: UITableViewController {
    
    @IBOutlet private weak var joystickModeCell: UITableViewCell!
    @IBOutlet private weak var twinsticksModeCell: UITableViewCell!
    
    @IBOutlet private weak var portASegmentedControl: UISegmentedControl!
    @IBOutlet private weak var portBSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var portCSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var portDSegmentedControl: UISegmentedControl!
    
    @IBOutlet private weak var step1Cell: UITableViewCell!
    @IBOutlet private weak var step2Cell: UITableViewCell!
    @IBOutlet private weak var step5Cell: UITableViewCell!
    @IBOutlet private weak var step10Cell: UITableViewCell!
    
    private var settingsState: SettingsState!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StoreCenter.store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        StoreCenter.store.unsubscribe(self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case joystickModeCell:
            StoreCenter.store.dispatch(SettingsAction.mode(.joystick))
        case twinsticksModeCell:
            StoreCenter.store.dispatch(SettingsAction.mode(.twinsticks))
            
        case step1Cell:
            StoreCenter.store.dispatch(SettingsAction.step(1))
        case step2Cell:
            StoreCenter.store.dispatch(SettingsAction.step(2))
        case step5Cell:
            StoreCenter.store.dispatch(SettingsAction.step(5))
        case step10Cell:
            StoreCenter.store.dispatch(SettingsAction.step(10))
            
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func directionChanged(_ sender: UISegmentedControl) {
        let direction = sender.selectedSegmentIndex == 1
        switch sender {
        case portASegmentedControl:
            StoreCenter.store.dispatch(SettingsAction.direction(.A, direction))
        case portBSegmentedControl:
            StoreCenter.store.dispatch(SettingsAction.direction(.B, direction))
        case portCSegmentedControl:
            StoreCenter.store.dispatch(SettingsAction.direction(.C, direction))
        case portDSegmentedControl:
            StoreCenter.store.dispatch(SettingsAction.direction(.D, direction))
        default:
            break
        }
    }
}

extension SettingsViewController: StoreSubscriber {
    
    func newState(state: State) {
        let settings = state.settingsState
        
        joystickModeCell.accessoryType = (settings.mode == .joystick) ? .checkmark : .none
        twinsticksModeCell.accessoryType = (settings.mode == .twinsticks) ? .checkmark : .none
        
        step1Cell.accessoryType = (settings.step == 1) ? .checkmark : .none
        step2Cell.accessoryType = (settings.step == 2) ? .checkmark : .none
        step5Cell.accessoryType = (settings.step == 5) ? .checkmark : .none
        step10Cell.accessoryType = (settings.step == 10) ? .checkmark : .none
        
        portASegmentedControl.selectedSegmentIndex = (settings.directions[.A] ?? true) ? 1 : 0
        portBSegmentedControl.selectedSegmentIndex = (settings.directions[.B] ?? true) ? 1 : 0
        portCSegmentedControl.selectedSegmentIndex = (settings.directions[.C] ?? true) ? 1 : 0
        portDSegmentedControl.selectedSegmentIndex = (settings.directions[.D] ?? true) ? 1 : 0
        
        settingsState = settings
    }
}
