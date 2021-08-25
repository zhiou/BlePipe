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
    public let remote: CBPeripheral
    
    public let advertisementData: [String: Any]
    
    public let rssi: Int
}

extension BPDiscovery: Nameable {
    public var displayName: String {
        return advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? remote.name ?? "Unkown Name"
    }
}

extension BPDiscovery: Equatable {
    public static func == (lhs: BPDiscovery, rhs: BPDiscovery) -> Bool {
        return lhs.remote.identifier == rhs.remote.identifier
    }
}
