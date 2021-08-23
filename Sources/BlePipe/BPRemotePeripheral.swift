//
//  BPRemotePeripheral.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth

public typealias BPPipeEndClosure = (BPPipeEnd?, BPError?) -> Void
public typealias BPBuildPipeCompletion = (BPError?) -> Void
public typealias BPWriteCompletion = (BPError?) -> Void

public class BPRemotePeripheral {
    private let peripheral: CBPeripheral
    private let configuration: BPConfiguration?
    
    private let delegateProxy: BPPeripheralDelegateProxy = BPPeripheralDelegateProxy()
    
    private var pipes: [CBUUID: BPPipeEnd] = [:]
    
    public init(peripheral: CBPeripheral, configuration: BPConfiguration) {
        self.peripheral = peripheral
        self.configuration = configuration
    }
    
    public init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.configuration = nil
    }
    
    public func buildPipes(_ completion: @escaping BPBuildPipeCompletion) {
        self.peripheral.delegate = delegateProxy
        delegateProxy.discovereCharacteristicCompletion = {
            completion(nil)
        }
        delegateProxy.discoverdCharacteristicsClosure = { [weak self] characteristics, err in
            if let err = err {
                completion(.sysError(err))
                return
            }
            guard let characteristics = characteristics else { return }
            for c in characteristics {
                guard let uuids = self?.configuration?.pipeEndUUIDs, uuids.contains(c.uuid) else { continue }
                let pipeEnd = BPPipeEnd(c, remote:self)
                self?.pipes[c.uuid] = pipeEnd
            }
        }
        peripheral.discoverServices(configuration?.serviceUUIDs)
    }
    
    func read(for characteristic: CBCharacteristic, closure: @escaping BPDataReceivedClosure) {
        delegateProxy.dataReceivedClosures[characteristic.uuid] = closure
        peripheral.readValue(for: characteristic)
    }
    
    public func write(data: Data, for characteristic: CBCharacteristic, closure: @escaping BPWriteCompletion) {
        delegateProxy.writeConfirmClosures[characteristic.uuid] = { error in
            if let error = error {
                closure(.sysError(error))
            } else {
                closure(nil)
            }
        }
        let type: CBCharacteristicWriteType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse;
        print(peripheral.state == .connected)
        print(characteristic.uuid.uuidString)
        if #available(iOS 11.0, *) {
            print(peripheral.canSendWriteWithoutResponse)
        } else {
            // Fallback on earlier versions
        }
        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
    }
    
    func subscribe(for characteristic: CBCharacteristic, closure: @escaping BPDataReceivedClosure) {
        delegateProxy.dataReceivedClosures[characteristic.uuid] = closure
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func unsubscribe(for characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(false, for: characteristic)
        delegateProxy.dataReceivedClosures[characteristic.uuid] = nil
    }
    
    deinit {
        print("remote peripheral deinit")
    }
}

extension BPRemotePeripheral: Equatable {
    public static func == (lhs: BPRemotePeripheral, rhs: BPRemotePeripheral) -> Bool {
        return lhs.peripheral.identifier == rhs.peripheral.identifier
    }
}

extension BPRemotePeripheral {
    public subscript(_ uuid: String) -> BPPipeEnd? {
        let cbuuid = CBUUID(string: uuid)
        return pipes[cbuuid]
    }
}
