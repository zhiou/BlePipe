//
//  BPPipe.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/11.
//

import CoreBluetooth

public typealias BPPacketReceivedClosure = (Data?, Error?) -> Void

public class BPPipeEnd {
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
    
    public func write(data: Data) throws {
        guard let remote = remote else {
            return
        }
        let packet = BPPacket(data: data, frameSize: remote.maxFrameSize)
        packets.append(packet)
        if packets.count > 0 {
            processPackets()
        }
    }
    
    public func subscribe(dataClosure: @escaping BPPacketReceivedClosure) {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        cache.clear()
        remote?.subscribe(for: characteristic, closure: { [weak self] frame, error in
            if let error = error {
                dataClosure(nil, error)
                return
            }
            if let frame = frame, let packet = self?.cache.process(frame) {
                dataClosure(packet, nil)
            }
        })
    }
    
    public func unsubscribe() {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        remote?.unsubscribe(for: characteristic)
    }
    
    private func processPackets() {
        guard let packet = packets.first else {
            return
        }
        if packet.finished {
            packets.remove(at: 0)
             processPackets()
        } else if let frame = packet.next {
            do {
                try remote?.write(data: frame, for: characteristic, completion: { [weak self] error in
                    self?.processPackets()
                })
            } catch {
                print("write data failed")
                return
            }
        }
    }
}
