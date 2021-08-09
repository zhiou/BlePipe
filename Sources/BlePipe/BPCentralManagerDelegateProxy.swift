//
//  File.swift
//  
//
//  Created by zhiou on 2021/8/9.
//

import CoreBluetooth

public typealias BPDiscoveredClosure = (BPDiscovery) -> Void

public typealias BPFilterClosure = (BPDiscovery) -> Bool

public typealias BPStateClosure = (CBManagerState) -> Void

class BPCentralManagerDelegateProxy: NSObject, CBCentralManagerDelegate {
    
    public var discoverdClosure: BPDiscoveredClosure?
    public var filterClosure: BPFilterClosure?
    public var stateClosure: BPStateClosure?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateClosure?(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let discovery = BPDiscovery(remote: peripheral, advertisementData: advertisementData, rssi: RSSI.intValue)
        if let filter = filterClosure, !filter(discovery) {
            return
        }
        discoverdClosure?(discovery)
    }
    
}
