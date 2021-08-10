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

public typealias BPConnectionClosure = (CBPeripheral, BPError?) -> Void

class BPCentralManagerDelegateProxy: NSObject, CBCentralManagerDelegate {
    
    public var discoverdClosure: BPDiscoveredClosure?
    public var filterClosure: BPFilterClosure?
    public var stateClosure: BPStateClosure?
    public var connectionClosure: BPConnectionClosure?
    
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
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionClosure?(peripheral, nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectionClosure?(peripheral, .sysError(error))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionClosure?(peripheral, .disconnect(error))
    }
    
}
