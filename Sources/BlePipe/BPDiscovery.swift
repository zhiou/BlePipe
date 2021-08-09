//
//  File.swift
//  
//
//  Created by zhiou on 2021/8/9.
//

import CoreBluetooth

protocol Nameable {
    var displayName: String { get }
}

public struct BPDiscovery {
    let remote: CBPeripheral
    
    let advertisementData: [String: Any]
    
    let rssi: Int
}

extension BPDiscovery: Nameable {
    var displayName: String {
        return advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? remote.name ?? "Unkown Name"
    }
}

extension BPDiscovery: Equatable {
    public static func == (lhs: BPDiscovery, rhs: BPDiscovery) -> Bool {
        return lhs.remote == rhs.remote
    }
}
