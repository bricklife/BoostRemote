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
        print("write", data.hexString)
        if let peripheral = peripheral, let characteristic = characteristic {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension MoveHubManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        func description() -> String {
            switch central.state {
            case .poweredOff:
                return "poweredOff"
            case .poweredOn:
                return "poweredOn"
            case .resetting:
                return "resetting"
            case .unauthorized:
                return "unauthorized"
            case .unknown:
                return "unknown"
            case .unsupported:
                return "unsupported"
            }
        }
        print(description())
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
        print(#function, error ?? "?")
        store.dispatch(ConnectAction.disconnect)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(#function, error ?? "")
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
        print(#function, characteristic.uuid, characteristic.value?.hexString ?? "nil", error ?? "")
        if let data = characteristic.value, let notification = Notification(data: data) {
            store.dispatch(NotificationAction(notification: notification))
        }
    }
}
