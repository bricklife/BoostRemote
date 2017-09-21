//
//  MoveHubManager.swift
//  BoostRemote
//
//  Created by ooba on 10/08/2017.
//  Copyright © 2017 bricklife.com. All rights reserved.
//

import Foundation
import CoreBluetooth
import ReSwift

class MoveHubManager: NSObject {
    
    static let shared = MoveHubManager()
    
    private var centralManager: CBCentralManager!
    
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func start() {
    }
    
    func startScan() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [MoveHubService.serviceUuid], options: nil)
        }
    }
    
    func stopScan() {
        centralManager.stopScan()
    }
    
    func connect(peripheral: CBPeripheral) {
        if self.peripheral == nil {
            self.peripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func disconnect() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            self.peripheral = nil
            self.characteristic = nil
        }
    }
    
    func set(characteristic: CBCharacteristic) {
        if let peripheral = peripheral, characteristic.properties.contains([.write, .notify]) {
            self.characteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            store.dispatch(ConnectAction.connect)
        }
    }
    
    func write(data: Data) {
        if let peripheral = peripheral, let characteristic = characteristic {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension MoveHubManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            store.dispatch(ConnectAction.offline)
        case .poweredOn:
            store.dispatch(ConnectAction.disconnect)
        case .resetting:
            store.dispatch(ConnectAction.disconnect)
        case .unauthorized:
            store.dispatch(ConnectAction.unsupported)
        case .unknown:
            store.dispatch(ConnectAction.unsupported)
        case .unsupported:
            store.dispatch(ConnectAction.unsupported)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        connect(peripheral: peripheral)
        stopScan()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([MoveHubService.serviceUuid])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        store.dispatch(ConnectAction.disconnect)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        store.dispatch(ConnectAction.disconnect)
    }
}

extension MoveHubManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == MoveHubService.serviceUuid }) {
            peripheral.discoverCharacteristics([MoveHubService.characteristicUuid], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristic = service.characteristics?.first(where: { $0.uuid == MoveHubService.characteristicUuid }) {
            set(characteristic: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value, let notification = Notification(data: data) {
            store.dispatch(NotificationAction(notification: notification))
        }
    }
}
