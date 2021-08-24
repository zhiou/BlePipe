//
//  BPPacket.swift
//  BPPacket
//
//  Created by zhiou on 2021/8/24.
//

import Foundation

class BPPacket {
    private let data: Data
    
    private let frameSize: Int
    
    private var offset = 0
    
    init(data: Data, frameSize: Int) {
        self.data = data
        self.frameSize = frameSize
    }
    
    var finished: Bool {
        return offset == data.count
    }
    
    var remainLength: Int {
        return data.count - offset
    }
    
    var next: Data? {
        let length = frameSize < remainLength ? frameSize : remainLength
        if let range = Range(NSRange(location: offset, length: length)) {
            offset += length;
            return data.subdata(in: range)
        }
        return nil
    }
}
