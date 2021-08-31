//
//  BP.swift
//  BP
//
//  Created by zhiou on 2021/8/26.
//

import CoreBluetooth

public enum BP {
    public static let peripheralManager = PMBuilder()
    
    public static let centralManager = CMBuilder()
}

extension BP {
    public class PMBuilder {
        let peripheralManager: BPPeripheralManager
        
        init() {
            self.peripheralManager = BPPeripheralManager()
        }
        
        deinit {
            print("builder deinit")
        }
    }
    
    public class CMBuilder {
        let centralManager: BPCentralManager
        let scanner: BPScanner
        
        init() {
            self.centralManager = BPCentralManager()
            self.scanner = BPScanner(centralManager: self.centralManager.cm)
        }
        
        deinit {
            print("builder deinit")
        }
    }
}

extension BP.PMBuilder {
    public func advertise(_ advertisementData: [String: Any]?) {
        self.peripheralManager.advertise(advertisementData: advertisementData)
    }
    
    @discardableResult
    public func service(_ build: (BPServiceBuilder) -> Void) -> Self {
        self.peripheralManager.service(build)
        return self
    }
    
    public func onPortBuilt(_ block: @escaping ((BPPort) -> Void)) -> Self {
        self.peripheralManager.portBuiltCallback = block
        return self
    }
}

extension BP.CMBuilder {
    public func service(_ uuidStrings: [String]) -> Self {
        self.centralManager.service(uuidStrings)
        return self
    }
    
    public func port(_ uuidString: String) -> Self {
        self.centralManager.port(uuidString)
        return self
    }
    
    public func build(_ identifier: UUID, completion: @escaping BPConnectCompletion) -> Self {
        self.centralManager.connect(identifier, completion: completion)
        return self
    }
}
