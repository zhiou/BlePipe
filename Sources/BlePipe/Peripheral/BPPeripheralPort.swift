//
//  BPPort.swift
//  BPPort
//
//  Created by zhiou on 2021/8/26.
//

import CoreBluetooth


public class BPPeripheralPort: BPPort {
    private let characteristic: CBCharacteristic
    private let remote: CBCentral
    private weak var pm: BPPeripheralManager?
    
    private var packageReceivedClosure: ((Data?, BPError?) -> Void)? = nil
    
    init(_ characteristic: CBCharacteristic, remote: CBCentral, pm: BPPeripheralManager?) {
        self.characteristic = characteristic
        self.remote = remote
        self.pm = pm
    }
    
    override func write(_ data: Data, completion: @escaping (BPError?) -> Void) throws {
        if let success = pm?.notify(characteristic as! CBMutableCharacteristic, remote: remote, data: data), success {
            completion(nil)
        } else {
            completion(BPError.sendFailed)
        }
    }
    
    override func receiving(_ receiving: @escaping BPDataReceivedClosure) throws {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        pm?.frameReceived(from:remote, receiving)
    }
    
    override func maxFrameSize() -> Int {
        return remote.maximumUpdateValueLength
    }
    
}


extension BPPeripheralPort: Equatable {
    public static func == (lhs: BPPeripheralPort, rhs: BPPeripheralPort) -> Bool {
        return lhs.remote.identifier == rhs.remote.identifier
        && lhs.characteristic.uuid == rhs.characteristic.uuid
    }
}
