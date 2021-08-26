//
//  BPPeripheralManager.swift
//  BPPeripheralManager
//
//  Created by zhiou on 2021/8/25.
//

import CoreBluetooth

public class BPCharacteristicBuilder {
    var uuidString: String = ""
    var properties: CBCharacteristicProperties = []
    
    var permissions: CBAttributePermissions = []
    var value: Data? = nil
    
    @discardableResult
    public func uuidString(_ uuidString: String) -> Self {
        self.uuidString = uuidString
        return self
    }
    
    @discardableResult
    public func properties(_ properties: CBCharacteristicProperties) -> Self {
        self.properties = properties
        return self
    }
    
    @discardableResult
    public func permissions(_ permissions: CBAttributePermissions) -> Self {
        self.permissions = permissions
        return self
    }
    
    @discardableResult
    public func value(_ value: Data?) -> Self {
        self.value = value
        return self
    }
}

public class BPServiceBuilder {
    var uuidString: String = ""
    var primary: Bool = false
    var characteristics: [CBMutableCharacteristic] = []
    
    @discardableResult
    public func characteristic(_ build: (BPCharacteristicBuilder) -> Void) -> Self {
        let builder = BPCharacteristicBuilder()
        build(builder)
        let characteristic = CBMutableCharacteristic(type: CBUUID(string: builder.uuidString), properties: builder.properties, value: builder.value, permissions: builder.permissions)
        characteristics.append(characteristic)
        return self
    }
    
    @discardableResult
    public func uuidString(_ uuidString: String) -> Self {
        self.uuidString = uuidString
        return self
    }
    
    @discardableResult
    public func primary(_ primary: Bool) -> Self {
        self.primary = primary
        return self
    }
}

public class BPPeripheralManager {
    private let peripheralManagerDelegateProxy = BPPeripheralManagerDelegateProxy()
    private lazy var pm = CBPeripheralManager(delegate: peripheralManagerDelegateProxy, queue: nil)
    
    private var ports: [BPPort] = [] // central.identifier : [port]
    
    public init() {
        peripheralManagerDelegateProxy.didAddService = { result in
        
        }
        
        peripheralManagerDelegateProxy.onWrite = { [unowned self] central, characteristic, data in
            var port = BPPort(characteristic, remote: central, pm: self)
            if !self.ports.contains(port) {
                self.ports.append(port)
            } else {
                if let index = self.ports.firstIndex(of: port) {
                    port = self.ports[index]
                }
            }
            port.onFrameReceived?(data)
        }
        
        peripheralManagerDelegateProxy.didSubscribeClosure = { central, characteristic in
            let port = BPPort(characteristic, remote: central, pm: self)
            if !self.ports.contains(port) {
                self.ports.append(port)
            }
        }
        
        peripheralManagerDelegateProxy.didUnsubscribeClosure = { central, characteristic in
            let port = BPPort(characteristic, remote: central, pm: self)
            if self.ports.contains(port) {
                if let index = self.ports.firstIndex(of: port) {
                    self.ports.remove(at: index)
                }
            }
        }
    }
    
    @discardableResult
    public func service(_ build: ((BPServiceBuilder) -> Void)) -> Self {
        let builder = BPServiceBuilder()
        build(builder)
        let service = CBMutableService(type: CBUUID(string: builder.uuidString), primary: builder.primary)
        service.characteristics?.append(contentsOf: builder.characteristics)
        pm.add(service)
        return self
    }
    
    public func advertise(advertisementData: [String: Any]?) {
        if !pm.isAdvertising {
            pm.startAdvertising(advertisementData)
        }
    }

    public func notify(_ characteristic: CBMutableCharacteristic, remote: CBCentral, data: Data, completion: @escaping BPPeripheralDidUpdateClosure) {
        peripheralManagerDelegateProxy.didUpdateClosure = completion
        pm.updateValue(data, for: characteristic, onSubscribedCentrals: [remote])
    }

}
