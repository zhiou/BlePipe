//
//  BPConnection.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth

public typealias BPConnectCompletion = (Result<BPRemotePeripheral, BPError>) -> Void


public class BPConnection {
    public let cm: CBCentralManager
    
    public let peripheral: CBPeripheral
    
    public let completion: BPConnectCompletion
    
    public var isConnected: Bool {
        return peripheral.state == .connected
    }
    
    init(cm: CBCentralManager, peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {
        self.cm = cm
        self.peripheral = peripheral
        self.completion = completion
    }
    
    public func start() {
        cm.connect(peripheral, options: nil)
    }
    
    public func stop() {
        cm.cancelPeripheralConnection(peripheral)
    }
}
