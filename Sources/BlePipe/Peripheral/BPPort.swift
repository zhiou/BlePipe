//
//  BPPort.swift
//  BPPort
//
//  Created by zhiou on 2021/8/26.
//

import CoreBluetooth


public class BPPort {
    private let characteristic: CBCharacteristic
    private let remote: CBCentral
    private weak var pm: BPPeripheralManager?
    
    private var packets: [BPPacket] = []
    
    private let cache: BPCache = BPCache()
    
    var onFrameReceived:((Data?) -> Void)? 
    
    init(_ characteristic: CBCharacteristic, remote: CBCentral, pm: BPPeripheralManager?) {
        self.characteristic = characteristic
        self.remote = remote
        self.pm = pm
    }
    
    public func notify(data: Data) throws {
        let packet = BPPacket(data: data, frameSize: remote.maximumUpdateValueLength)
        packets.append(packet)
        if packets.count > 0 {
            processPackets()
        }
    }
    
    public func onWrite(dataClosure: @escaping BPPacketReceivedClosure) {
        guard characteristic.properties.contains(.notify) else {
            return
        }
        cache.clear()
        if onFrameReceived == nil {
            onFrameReceived =  { [weak self] frame in
                if let frame = frame, let packet = self?.cache.process(frame) {
                    dataClosure(packet, nil)
                }
            }
        }
    }
    
    private func processPackets() {
        guard let packet = packets.first else {
            return
        }
        if packet.finished {
            packets.remove(at: 0)
            processPackets()
        } else if let frame = packet.next {
            pm?.notify(characteristic as! CBMutableCharacteristic, remote: remote, data: frame) { [weak self] in
                self?.processPackets()
            }
            
        }
    }
}


extension BPPort: Equatable {
    public static func == (lhs: BPPort, rhs: BPPort) -> Bool {
        return lhs.remote.identifier == rhs.remote.identifier
        && lhs.characteristic.uuid == rhs.characteristic.uuid
    }
}
