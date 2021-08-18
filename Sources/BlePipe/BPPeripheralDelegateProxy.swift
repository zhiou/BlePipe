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
public typealias BPDiscovereCharacteristicCompletion = () -> Void

class BPPeripheralDelegateProxy: NSObject, CBPeripheralDelegate {
    
    var discoverdCharacteristicsClosure: BPDiscoveredCharacteristicClosure?
    var dataReceivedClosures: [CBUUID: BPDataReceivedClosure] = [:]
    var writeConfirmClosures: [CBUUID: BPWriteConfirmClosure] = [:]
    var discovereCharacteristicCompletion: BPDiscovereCharacteristicCompletion?
    
    private var discoverServiceCount: Int = 0 {
        willSet {
            if discoverServiceCount != 0, newValue == 0 {
                discovereCharacteristicCompletion?()
            }
        }
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach({ service in
            discoverServiceCount += 1
            peripheral.discoverCharacteristics(nil, for: service)
            print("discover service" + service.uuid.uuidString)
        })
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("did discover service" + service.uuid.uuidString)
        discoverdCharacteristicsClosure?(service.characteristics, error)
        discoverServiceCount -= 1
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        dataReceivedClosures[characteristic.uuid]?(characteristic.value, error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        writeConfirmClosures[characteristic.uuid]?(error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            dataReceivedClosures[characteristic.uuid]?(nil, error)
        }
    }
}
