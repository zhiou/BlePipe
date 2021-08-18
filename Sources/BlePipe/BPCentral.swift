//
//  BPConnector.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth


public class BPCentral {
    
    private let delegateProxy = BPCentralManagerDelegateProxy()
    
    private lazy var cm = CBCentralManager(delegate: delegateProxy, queue: nil, options: nil)
    
    private var connections: [BPConnection] = []
    
    private let syncQueue = DispatchQueue(label: "com.zzstudio.bp.sync")
    
    private var pipes: [UUID: BPPipeEnd] = [:]
    
    public init() {
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
        let dataServiceUUID = CBUUID(string: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")
        let dataServiceCharacteristicUUID = CBUUID(string: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")
        let config = BPConfiguration(serviceUUIDs: [dataServiceUUID], allowDuplicates: false, pipeEndUUIDs: [dataServiceCharacteristicUUID])
        let remotePeripheral = BPRemotePeripheral(peripheral: peripheral, configuration: config)
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
                let error: BPError = .alreadyConnected
                completion(nil, error)
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
