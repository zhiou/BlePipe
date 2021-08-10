//
//  BPConnector.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth


public class BPCentral {
    
    private let scanner = BPScanner()
    
    private let delegateProxy = BPCentralManagerDelegateProxy()
    
    private lazy var cm = CBCentralManager(delegate: delegateProxy, queue: nil, options: nil)
    
    private var connections: [BPConnection] = []
    
    
    public init() {
        delegateProxy.connectClosure = { [weak self] peripheral, error in
            guard let c = self?.connections.filter({$0.peripheral.identifier == peripheral.identifier}).first else{
                return
            }
            if let error = error {
                c.completion(nil, error)
            } else {
                c.completion(BPRemotePeripheral(peripheral: peripheral), nil)
            }
            
        }
    }
    
    public func connect(peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {
        if let c = connections.filter({$0.peripheral.identifier == peripheral.identifier}).first {
            let error: BPError = c.peripheral.state == .connected ? .alreadyConnected : .alreadyConnecting
            completion(nil, error)
        }

        let peripherals = self.cm.retrievePeripherals(withIdentifiers: [peripheral.identifier])
        guard let target = peripherals.first else {
            completion(nil, .notFound)
            return
        }
        let connection = BPConnection(cm: cm, peripheral: target, completion: completion)
        connections.append(connection)
        connection.run()
    }
    
    
}
