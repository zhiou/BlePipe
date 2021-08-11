//
//  File.swift
//  
//
//  Created by zhiou on 2021/8/9.
//

import CoreBluetooth

public struct BPConfiguration {
    var serviceUUIDs: [CBUUID]
    var allowDuplicates: Bool
    var pipeEndUUIDs: [CBUUID]
}
