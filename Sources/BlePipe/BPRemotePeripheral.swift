//
//  BPRemotePeripheral.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth

public typealias BPPipeEndClosure = (BPPipeEnd?, BPError?) -> Void
public typealias BPWriteCompletion = (BPError?) -> Void

public class BPRemotePeripheral {
    private let peripheral: CBPeripheral
    private let configuration: BPConfiguration?
    
    private let delegateProxy: BPPeripheralDelegateProxy = BPPeripheralDelegateProxy()
    
    public init(peripheral: CBPeripheral, configuration: BPConfiguration) {
        self.peripheral = peripheral
        self.configuration = configuration
    }
    
    public init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.configuration = nil
    }
    
    public func buildPipes(closure: @escaping BPPipeEndClosure) {
        delegateProxy.discoverdCharacteristicsClosure = { [weak self] characteristics, err in
            if let err = err {
                closure(nil, .sysError(err))
                return
            }
            guard let characteristics = characteristics else { return }
            for c in characteristics {
                guard let uuids = self?.configuration?.pipeEndUUIDs, uuids.contains(c.uuid) else { continue }
                let pipeEnd = BPPipeEnd(c, remote:self)
                closure(pipeEnd, nil)
            }
        }
        peripheral.discoverServices(configuration?.serviceUUIDs)
    }
    
    func read(for characteristic: CBCharacteristic, closure: @escaping BPDataReceivedClosure) {
        delegateProxy.dataReceivedClosures[characteristic.uuid] = closure
        peripheral.readValue(for: characteristic)
    }
    
    func write(data: Data, for characteristic: CBCharacteristic, closure: @escaping BPWriteCompletion) {
        delegateProxy.writeConfirmClosures[characteristic.uuid] = { error in
            if let error = error {
                closure(.sysError(error))
            } else {
                closure(nil)
            }
        }
        let type: CBCharacteristicWriteType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse;
        peripheral.writeValue(data, for: characteristic, type: type)
    }
    
    func subscribe(for characteristic: CBCharacteristic, closure: @escaping BPDataReceivedClosure) {
        delegateProxy.dataReceivedClosures[characteristic.uuid] = closure
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func unsubscribe(for characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(false, for: characteristic)
        delegateProxy.dataReceivedClosures[characteristic.uuid] = nil
    }

}
