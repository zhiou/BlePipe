//
//  BPPort.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/31.
//

import Foundation


public class BPPort {
    
    private var packets: [BPPacket] = []
    
    private let cache: BPCache = BPCache()
    
    func maxFrameSize() -> Int {
        return 20
    }
    
    public func send(data: Data) {
        let packet = BPPacket(data: data, frameSize: self.maxFrameSize())
        packets.append(packet)
        if packets.count > 0 {
            processPackets()
        }
    }
    
    public func recv(dataClosure: @escaping BPPacketReceivedClosure) {
        cache.clear()
        try? self.onFrame { [weak self] frame, error in
            if let error = error {
                dataClosure(nil, error)
                return
            }
            if let frame = frame, let packet = self?.cache.process(frame) {
                dataClosure(packet, nil)
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
            do {
                try self.write(frame, completion: { [weak self] error in
                    if let _ = error  {
                        return
                    }
                    self?.processPackets()
                })
            } catch {
                print("write data failed")
                return
            }
        }
    }
    
    func write(_ data: Data, completion: @escaping (BPError?) -> Void) throws {
        throw BPError.notImpl
    }
    
    func onFrame(_ receiving: @escaping BPDataReceivedClosure) throws {
        throw BPError.notImpl
    }
}
