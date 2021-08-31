//
//  BPConnector.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth


public class BPCentralManager {
    
    private let queue = DispatchQueue(label: "com.bp.cm.queue")
    
    lazy var cm = CBCentralManager(delegate: delegateProxy, queue: queue)
    
    private let delegateProxy = BPCentralManagerDelegateProxy()
    
    private var connections: [BPConnection] = []
    
    private let syncQueue = DispatchQueue(label: "com.zzstudio.bp.sync")
    
    private var serviceUUIDs: [CBUUID] = []
    
    private var portUUIDs: [CBUUID] = []
    
    deinit {
        print("BPCentralManager deinit")
    }
    
    public init() {
        self.connections = []
        delegateProxy.connectionClosure = { [weak self] peripheral, error in
            guard let c = self?.connections.filter({$0.peripheral.identifier == peripheral.identifier}).first else{
                return
            }
            if let error = error {
                c.completion(Result.failure(error))
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
    
    @discardableResult
    public func service(_ uuidStrings: [String]) -> Self {
        self.serviceUUIDs = uuidStrings.map(CBUUID.init(string:))
        return self
    }
    
    @discardableResult
    public func port(_ uuidString: String) -> Self {
        let uuid = CBUUID(string: uuidString)
        if !self.portUUIDs.contains(uuid) {
            self.portUUIDs.append(uuid)
        }
        return self
    }
    
    private func onConnected(_ peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {
        
        let remotePeripheral = BPRemotePeripheral(peripheral: peripheral)
        remotePeripheral
            .buildPipes(service: self.serviceUUIDs,
                        ports: self.portUUIDs)
            { [weak self] error in
                if let error = error {
                    self?.cm.cancelPeripheralConnection(peripheral)
                    completion(Result.failure(error))
                } else {
                    completion(Result.success(remotePeripheral))
                }
            }
    }
    
    private func onDisconnected(_ peripheral: CBPeripheral, completion: BPConnectCompletion) {
        let remotePeripheral = BPRemotePeripheral(peripheral: peripheral)
        completion(Result.success(remotePeripheral))
    }
    
    public func connect(_ identifier: UUID, completion: @escaping BPConnectCompletion) {
        cm.delegate = delegateProxy
        guard let c = connections.filter({$0.peripheral.identifier == identifier}).first else {
                var peripherals = self.cm.retrievePeripherals(withIdentifiers: [identifier])
            if peripherals.isEmpty {
                peripherals = self.cm.retrieveConnectedPeripherals(withServices: self.serviceUUIDs)
            }
            guard let target = peripherals.first else {
                completion(Result.failure(.notFound))
                return
            }
            let connection = BPConnection(cm: cm, peripheral: target, completion: completion)
            syncQueue.sync { [weak self] in
                self?.connections.append(connection)
            }
            connection.start()
            return
        }
        guard c.peripheral.state != .connected else {
            completion(Result.success(BPRemotePeripheral(peripheral: c.peripheral)))
            return
        }
        
        c.start()
    }
    
    public func disconnect(_ peripheral: CBPeripheral, completion: @escaping BPConnectCompletion) {
        cm.delegate = delegateProxy
        guard let c = connections.filter({$0.peripheral.identifier == peripheral.identifier}).first else {
            completion(Result.failure(.notFound))
            return
        }
        
        guard c.peripheral.state == .connected || c.peripheral.state == .connecting else {
            completion(Result.failure(.alreadyConnected))
            return
        }
        c.stop()
    }
    
    
}
