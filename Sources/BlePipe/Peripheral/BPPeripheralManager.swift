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
        let characteristic = CBMutableCharacteristic(type: CBUUID(string: builder.uuidString),
                                                     properties: builder.properties,
                                                     value: builder.value,
                                                     permissions: builder.permissions)
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
    
    private lazy var pm = CBPeripheralManager(delegate: peripheralManagerDelegateProxy, queue: DispatchQueue.init(label: "com.bp.pm.queue"))
    
    public var ports: [BPPeripheralPort] = [] // central.identifier : [port]
    private var advertisementData: [String: Any]? = nil
    private var services: [CBMutableService] = []
    var portBuiltCallback: ((BPPeripheralPort) -> Void)? = nil
    
    private let sem = DispatchSemaphore(value: 1)
    
    private var frameDidReceive: [UUID: BPDataReceivedClosure] = [:]
    
    deinit {
        print("pm deinit")
    }
    
    public init() {
        peripheralManagerDelegateProxy.didAddService = { [unowned self] result in
            print("did add service")
            if !self.pm.isAdvertising {
                self.pm.startAdvertising(self.advertisementData)
            }
        }
        
        peripheralManagerDelegateProxy.onWrite = { [unowned self] central, characteristic, data in
            var port = BPPeripheralPort(characteristic, remote: central, pm: self)
            if !self.ports.contains(port) {
                self.ports.append(port)
                portBuiltCallback?(port)
            } else {
                if let index = self.ports.firstIndex(of: port) {
                    port = self.ports[index]
                }
            }
            frameDidReceive[central.identifier]?(data, nil)
        }
        
        peripheralManagerDelegateProxy.didSubscribeClosure = { central, characteristic in
            let port = BPPeripheralPort(characteristic, remote: central, pm: self)
            if !self.ports.contains(port) {
                self.ports.append(port)
                self.portBuiltCallback?(port)
            }
        }
        
        peripheralManagerDelegateProxy.didUnsubscribeClosure = { central, characteristic in
            let port = BPPeripheralPort(characteristic, remote: central, pm: self)
            if self.ports.contains(port) {
                if let index = self.ports.firstIndex(of: port) {
                    self.ports.remove(at: index)
                }
            }
        }
        
        peripheralManagerDelegateProxy.didUpdateState = { [unowned self] state in
            if case state = CBManagerState.poweredOn {
                self.services.forEach { service in
                    self.pm.add(service)
                }
            }
        }
        
        peripheralManagerDelegateProxy.didUpdateClosure = { [unowned self] in
            self.sem.signal()
        }
        
    }
    
    @discardableResult
    public func service(_ build: ((BPServiceBuilder) -> Void)) -> Self {
        let builder = BPServiceBuilder()
        build(builder)
        let service = CBMutableService(type: CBUUID(string: builder.uuidString), primary: builder.primary)
        service.characteristics = builder.characteristics

        services.append(service)
        return self
    }
    
    public func advertise(advertisementData: [String: Any]?) {
        if self.pm.isAdvertising {
            pm.stopAdvertising()
            pm.startAdvertising(advertisementData)
        } else {
            self.advertisementData = advertisementData
        }
    }
    
    @discardableResult
    public func frameReceived(from central: CBCentral, _ closure: @escaping BPDataReceivedClosure) -> Self {
        frameDidReceive[central.identifier] = closure
        return self
    }

    public func notify(_ characteristic: CBMutableCharacteristic, remote: CBCentral, data: Data) -> Bool {
        if !pm.updateValue(data, for: characteristic, onSubscribedCentrals: [remote]) {
            sem.wait()
            return pm.updateValue(data, for: characteristic, onSubscribedCentrals: [remote])
        }
        return true
    }
}
