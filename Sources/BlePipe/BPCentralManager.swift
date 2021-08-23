//
//  BPConnector.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth


public class BPCentralManager {
    
    private let cm: CBCentralManager
    
    private let delegateProxy = BPCentralManagerDelegateProxy()
    
    private var connections: [BPConnection] = []
    
    private let syncQueue = DispatchQueue(label: "com.zzstudio.bp.sync")
    
    private var pipes: [UUID: BPPipeEnd] = [:]
    
    private var config: BPConfiguration
    
    public init(centralManager: CBCentralManager, config: BPConfiguration) {
        self.cm = centralManager
        self.config = config
        cm.delegate = delegateProxy;
        delegateProxy.connectionClosure = { [weak self] peripheral, error in
            guard let c = self?.connections.filter({$0.peripheral.identifier == peripheral.identifier}).first else{
                return
            }
            if let error = error {
                c.completion(nil, error)
                if let index = self?.connections.firstIndex(where: { $0.peripheral.identifier == c.peripheral.identifier }) {
                    self?.syncQueue.async { [weak self] in
                        self?.connections.remove(at: index)
                    }
                }
            }
            switch peripheral.state {
            case .connected:
                self?.onConnected(peripheral, completion: c.completion)
            case .disconnected:
                self?.onDisconnected(peripheral, completion: c.completion)
            default:
                print(peripheral.state)
            }
        }

    }
    
    private func onConnected(_ peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {

        let remotePeripheral = BPRemotePeripheral(peripheral: peripheral, configuration: self.config)
        remotePeripheral.buildPipes { [weak self] pe, err in
            if let err = err {
                self?.cm.cancelPeripheralConnection(peripheral)
                completion(nil, err)
                return
            }
            if let pe = pe {
                self?.pipes[peripheral.identifier] = pe
                let data = Data([0x00, 0x01, 0x02, 0x03])
                pe.write(data: data) { error in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(remotePeripheral, nil)
                    }
                }
            }
        } completion: { [weak self] in
            if let pc = self?.pipes.count, pc == 0 {
                self?.cm.cancelPeripheralConnection(peripheral)
                completion(nil, .noPipeEnd)
            }
        }
    }
    
    private func onDisconnected(_ peripheral: CBPeripheral, completion: BPConnectCompletion) {
        self.pipes = [:]
        let remotePeripheral = BPRemotePeripheral(peripheral: peripheral)
        completion(remotePeripheral, nil)
    }
    
    public func connect(_ peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {
        guard let c = connections.filter({$0.peripheral.identifier == peripheral.identifier}).first else {
            let peripherals = self.cm.retrievePeripherals(withIdentifiers: [peripheral.identifier])
            guard let target = peripherals.first else {
                completion(nil, .notFound)
                return
            }
            let connection = BPConnection(cm: cm, peripheral: target, completion: completion)
            syncQueue.async { [weak self] in
                self?.connections.append(connection)
            }
            connection.start()
            return
        }
        guard c.peripheral.state != .connected else {
                completion(BPRemotePeripheral(peripheral: peripheral), nil)
            return
        }
        
        c.start()
    }
    
    public func disconnect(_ peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {
        guard let c = connections.filter({$0.peripheral.identifier == peripheral.identifier}).first else {
            completion(nil, .notFound)
            return
        }
        
        guard c.peripheral.state == .connected || c.peripheral.state == .connecting else {
            completion(nil, .alreadyDisconnected)
            return
        }
        c.stop()
    }
    
    
}
