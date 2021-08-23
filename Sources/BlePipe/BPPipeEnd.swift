//
//  BPPipe.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/11.
//

import CoreBluetooth

public class BPPipeEnd {
    private let characteristic: CBCharacteristic
    private weak var remote: BPRemotePeripheral?
    
    init(_ characteristic: CBCharacteristic, remote: BPRemotePeripheral?) {
        self.characteristic = characteristic
        self.remote = remote
    }
    
    public func read(dataClosure: @escaping BPDataReceivedClosure) {
        guard characteristic.properties.contains(.read) else {
            return
        }
        remote?.read(for: characteristic, closure:dataClosure)
    }
    
    public func write(data: Data, completion: @escaping BPWriteCompletion) {
        guard characteristic.properties.contains(.write), characteristic.properties.contains(.writeWithoutResponse) else {
            return
        }
        remote?.write(data: data, for: characteristic, closure: completion)
    }
    
    public func subscribe(dataClosure: @escaping BPDataReceivedClosure) {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        remote?.subscribe(for: characteristic, closure: dataClosure)
    }
    
    public func unsubscribe() {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        remote?.unsubscribe(for: characteristic)
    }
}
