//
//  BPCache.swift
//  BPCache
//
//  Created by zhiou on 2021/8/24.
//

import Foundation

public protocol BPPacketProcessor {
    func check(buffer: Data, frame: Data) -> Data?
}

extension BPPacketProcessor {
    func check(buffer: Data, frame: Data) ->  Data? {
        if frame == "EOD".data(using: .utf8) {
            return buffer
        }
        return nil
    }
}

class BPCache: BPPacketProcessor {
    private var buffer: Data
    
    init() {
        buffer = Data()
    }
    
    func clear() {
        buffer = Data()
    }
    
    func process(_ frame: Data) -> Data? {
        if let packet = check(buffer: buffer, frame: frame) {
            buffer = Data()
            return packet
        }
        buffer.append(contentsOf: frame)
        return nil
    }

}
