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
        let finished = check(buffer: buffer, frame: frame)
        buffer.append(contentsOf: frame)
        return finished ? buffer : nil
    }
    
    private func check(buffer: Data, frame: Data) -> Bool {
        return frame == "EOD".data(using: .utf8)
    }
}
