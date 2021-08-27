//
//  BPCache.swift
//  BPCache
//
//  Created by zhiou on 2021/8/24.
//

import Foundation

class BPCache {
    private var buffer: Data
    
    init() {
        buffer = Data()
    }
    
    func clear() {
        buffer = Data()
    }
    
    func process(_ frame: Data) -> Data? {
//        print("frame size \(frame)")
        let finished = check(buffer: buffer, frame: frame)
        if finished {
            let packet = buffer;
            buffer = Data()
            return packet
        }
        buffer.append(contentsOf: frame)
        return nil
    }
    
    private func check(buffer: Data, frame: Data) -> Bool {
        return frame == "EOD".data(using: .utf8)
    }
}
