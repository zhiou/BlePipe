//
//  BPRemotePeripheral.swift
//  BlePipe
//
//  Created by zhiou on 2021/8/10.
//

import CoreBluetooth

public typealias BPPipeEndClosure = (BPCentralPort?, BPError?) -> Void
public typealias BPBuildPipeCompletion = (BPError?) -> Void
public typealias BPWriteCompletion = (BPError?) ->  Void


public class BPRemotePeripheral {
    private let peripheral: CBPeripheral
    
    private let delegateProxy: BPPeripheralDelegateProxy = BPPeripheralDelegateProxy()
    
    private var pipes: [CBUUID: BPCentralPort] = [:]
    
    private lazy var writeQueue: DispatchQueue = DispatchQueue(label: "com.bp.write.queue")
    
    private let sem =  DispatchSemaphore(value: 0)
    
    public var maxFrameSize: Int {
        if #available(iOS 9.0, *) {
            return peripheral.maximumWriteValueLength(for: .withoutResponse)
        } else {
            return 20
        }
    }
    
    public init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        delegateProxy.readyForWriteClosure = { [weak self] in
            self?.sem.signal()
        }
    }

    
    public func buildPipes(service: [CBUUID], ports: [CBUUID], completion: @escaping BPBuildPipeCompletion) {
        self.peripheral.delegate = delegateProxy
        delegateProxy.discovereCharacteristicCompletion = {
            completion(nil)
        }
        delegateProxy.discoverdCharacteristicsClosure = { [weak self] characteristics, err in
            if let err = err {
                completion(.sysError(err))
                return
            }
            guard let characteristics = characteristics else { return }
            for c in characteristics {
                guard ports.contains(c.uuid) else { continue }
                let pipeEnd = BPCentralPort(c, remote:self)
                self?.pipes[c.uuid] = pipeEnd
            }
        }
        peripheral.discoverServices(service)
    }
    
    func read(for characteristic: CBCharacteristic, closure: @escaping BPDataReceivedClosure) {
        delegateProxy.dataReceivedClosures[characteristic.uuid] = closure
        peripheral.readValue(for: characteristic)
    }
    
    public func write(data: Data, for characteristic: CBCharacteristic, completion: @escaping BPWriteCompletion) throws {
        guard characteristic.properties.contains(.write),
              characteristic.properties.contains(.writeWithoutResponse) else {
            throw BPError.invalidPort
        }
        
        guard peripheral.state == .connected else {
            throw BPError.alreadyDisconnected
        }
        
        if characteristic.properties.contains(.writeWithoutResponse) {
            /// It won't work if system version is lower than iOS  11.0
            guard #available(iOS 11.0, *) else {
                /// Sleeping at most 8ms every frame can prevent sending task from fail.
                peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
                writeQueue.async {
                    usleep(useconds_t(data.count * 400))
                    completion(nil)
                }
                return
            }
            if !peripheral.canSendWriteWithoutResponse {
                self.sem.wait()
            }
            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
            writeQueue.async {
                completion(nil)
            }
        } else {
            delegateProxy.writeConfirmClosures[characteristic.uuid] = { error in
                guard error == nil else {
                    completion(.sysError(error))
                    return
                }
                completion(nil)
            }
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    
    func subscribe(for characteristic: CBCharacteristic, closure: @escaping BPDataReceivedClosure) {
        delegateProxy.dataReceivedClosures[characteristic.uuid] = closure
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    func unsubscribe(for characteristic: CBCharacteristic) {
        peripheral.setNotifyValue(false, for: characteristic)
        delegateProxy.dataReceivedClosures[characteristic.uuid] = nil
    }
    
    deinit {
        print("remote peripheral deinit")
    }
}

extension BPRemotePeripheral: Equatable {
    public static func == (lhs: BPRemotePeripheral, rhs: BPRemotePeripheral) -> Bool {
        return lhs.peripheral.identifier == rhs.peripheral.identifier
    }
}

extension BPRemotePeripheral {
    public subscript(_ uuid: String) -> BPCentralPort? {
        let cbuuid = CBUUID(string: uuid)
        return pipes[cbuuid]
    }
}
