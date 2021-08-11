//
//  BPPeripheralDelegateProxy.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/11.
//

import CoreBluetooth


public typealias BPDiscoveredCharacteristicClosure = ([CBCharacteristic]?, Error?) -> ()
public typealias BPDataReceivedClosure = (Data?, Error?) -> Void
public typealias BPWriteConfirmClosure = (Error?) -> Void

class BPPeripheralDelegateProxy: NSObject, CBPeripheralDelegate {
    
    var discoverdCharacteristicsClosure: BPDiscoveredCharacteristicClosure?
    var dataReceivedClosures: [CBUUID: BPDataReceivedClosure] = [:]
    var writeConfirmClosures: [CBUUID: BPWriteConfirmClosure] = [:]
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ service in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        discoverdCharacteristicsClosure?(service.characteristics, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        dataReceivedClosures[characteristic.uuid]?(characteristic.value, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        writeConfirmClosures[characteristic.uuid]?(error)
    }
}
