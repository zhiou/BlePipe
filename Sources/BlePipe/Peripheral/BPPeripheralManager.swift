//
//  BPPeripheralManager.swift
//  BPPeripheralManager
//
//  Created by zhiou on 2021/8/25.
//

import CoreBluetooth


class BPPeripheralManager {
    private let peripheralManagerDelegateProxy = BPPeripheralManagerDelegateProxy()
    private lazy var pm = CBPeripheralManager(delegate: peripheralManagerDelegateProxy, queue: nil)
    
    func advertise() {
        pm.startAdvertising(<#T##advertisementData: [String : Any]?##[String : Any]?#>)
    }
}
