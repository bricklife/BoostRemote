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
    @IBOutlet private weak var stepStepper: UIStepper!
    @IBOutlet private weak var stepLabel: UILabel!

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
        switch indexPath.row {
        case 0:
            StoreCenter.store.dispatch(SettingsAction.selectMode(.joystick))
        case 1:
            StoreCenter.store.dispatch(SettingsAction.selectMode(.twinsticks))
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func tappedStepper(_ sender: Any) {
        if stepStepper.value > settingsState.step {
            StoreCenter.store.dispatch(SettingsAction.incrementStep)
        } else if stepStepper.value < settingsState.step {
            StoreCenter.store.dispatch(SettingsAction.decrementStep)
        }
    }
}

extension SettingsViewController: StoreSubscriber {
    
    func newState(state: State) {
        let settings = state.settingsState
        
        joystickModeCell.accessoryType = (settings.mode == .joystick) ? .checkmark : .none
        twinsticksModeCell.accessoryType = (settings.mode == .twinsticks) ? .checkmark : .none
        stepStepper.value = settings.step
        stepLabel.text = "\(settings.step)"
        
        settingsState = settings
    }
}
