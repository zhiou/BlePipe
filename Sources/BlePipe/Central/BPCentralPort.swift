//
//  BPPipe.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/11.
//

import CoreBluetooth

public typealias BPPacketReceivedClosure = (Data?, Error?) -> Void

public class BPCentralPort: BPPort {
    private let characteristic: CBCharacteristic
    private weak var remote: BPRemotePeripheral?
    
    private var packets: [BPPacket] = []
    
    private let cache: BPCache = BPCache()
    
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
    
    override func write(_ data: Data, completion: @escaping (BPError?) -> Void) throws {
        guard let remote = remote else {
            return
        }
        try remote.write(data: data, for: characteristic, completion: completion)
    }
    
    override func onFrame(_ receiving: @escaping BPDataReceivedClosure) throws {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        remote?.subscribe(for: characteristic, closure: receiving)
    }
    
    override func maxFrameSize() -> Int {
        return remote?.maxFrameSize ?? 20
    }
    
    public func unsubscribe() {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        remote?.unsubscribe(for: characteristic)
    }
}
