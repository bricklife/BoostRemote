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
import BoostBLEKit

class MoveHubManager: NSObject {
    
    static let shared = MoveHubManager()
    
    private var centralManager: CBCentralManager!
    
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    private var connectedHub: Hub?
    private var isInitializingHub = false
    
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
    
    func connect(peripheral: CBPeripheral, advertisementData: [String : Any]) -> Bool {
        guard self.peripheral == nil else { return false }
        
        guard let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data else { return false }
        guard let hubType = HubType(manufacturerData: manufacturerData) else { return false }
        
        switch hubType {
        case .boost:
            self.connectedHub = Boost.MoveHub()
        case .boostV1:
            self.connectedHub = Boost.MoveHubV1()
        case .poweredUp:
            self.connectedHub = PoweredUp.SmartHub()
        case .duploTrain:
            self.connectedHub = Duplo.TrainBase()
        case .controlPlus:
            self.connectedHub = ControlPlus.SmartHub()
        case .spikeEssential:
            self.connectedHub = Spike.EssentialHub()
        default:
            return false
        }
        
        self.isInitializingHub = true
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
        
        return true
    }
    
    func disconnect() {
        write(data: Data([0x04, 0x00, 0x02, 0x01])) // Switch Off Hub
    }
    
    func reset() {
        self.peripheral = nil
        self.characteristic = nil
        self.connectedHub = nil
        self.isInitializingHub = false
    }
    
    func set(characteristic: CBCharacteristic) {
        if let hub = connectedHub, let peripheral = peripheral, characteristic.properties.contains([.write, .notify]) {
            self.characteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            StoreCenter.store.dispatch(ConnectAction.connect(hub))
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
            StoreCenter.store.dispatch(ConnectAction.offline)
        case .poweredOn:
            StoreCenter.store.dispatch(ConnectAction.disconnect)
        case .resetting:
            StoreCenter.store.dispatch(ConnectAction.disconnect)
        case .unauthorized:
            StoreCenter.store.dispatch(ConnectAction.unauthorized)
        case .unknown:
            StoreCenter.store.dispatch(ConnectAction.unsupported)
        case .unsupported:
            StoreCenter.store.dispatch(ConnectAction.unsupported)
        @unknown default:
            StoreCenter.store.dispatch(ConnectAction.unsupported)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if connect(peripheral: peripheral, advertisementData: advertisementData) {
            stopScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([MoveHubService.serviceUuid])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        reset()
        StoreCenter.store.dispatch(ConnectAction.disconnect)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        reset()
        StoreCenter.store.dispatch(ConnectAction.disconnect)
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
            StoreCenter.store.dispatch(NotificationAction(notification: notification))
            
            switch notification {
            case .connected(let portId, let ioType):
                connectedHub?.connectedIOs[portId] = ioType
            case .disconnected(let portId):
                connectedHub?.connectedIOs[portId] = nil
            default:
                break
            }
            
            if isInitializingHub {
                isInitializingHub = false
                write(data: HubPropertiesCommand(property: .batteryVoltage, operation: .enableUpdates).data)
            }

        }
    }
}
