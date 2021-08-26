//
//  BPPeripheralManagerDelegateProxy.swift
//  BPPeripheralManagerDelegateProxy
//
//  Created by zhiou on 2021/8/25.
//

import CoreBluetooth

public typealias BPPeripheralDidAddServiceClosure = (Result<CBService, BPError>) -> Void
public typealias BPPeripheralOnWriteClosure = (CBCentral, CBCharacteristic, Data?) -> Void
public typealias BPPeripheralDidUpdateClosure = () -> Void
public typealias BPPeripheralDidSubscribeClosure = (CBCentral, CBCharacteristic) -> Void
public typealias BPPeripheralDidUnsubscribeClosure = (CBCentral, CBCharacteristic) -> Void

class BPPeripheralManagerDelegateProxy: NSObject, CBPeripheralManagerDelegate {
    
    var didAddService: BPPeripheralDidAddServiceClosure?
    var onWrite: BPPeripheralOnWriteClosure?
    var didUpdateClosure: BPPeripheralDidUpdateClosure?
    var didSubscribeClosure: BPPeripheralDidSubscribeClosure?
    var didUnsubscribeClosure:BPPeripheralDidUnsubscribeClosure?
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        requests.forEach { request in
            onWrite?(request.central, request.characteristic, request.value)
        }
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        didSubscribeClosure?(central, characteristic)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        didUnsubscribeClosure?(central, characteristic)
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        didUpdateClosure?()
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            didAddService?(Result.failure(.sysError(error)))
            return
        }
        didAddService?(Result.success(service))
    }
    
}
