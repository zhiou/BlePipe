//
//  BP.swift
//  BP
//
//  Created by zhiou on 2021/8/26.
//

import Foundation

public enum BP {
    public static func peripheralManager() -> BP.Builder {
        return Builder()
    }
}

extension BP {
    public class Builder {
        let peripheralManager: BPPeripheralManager
        
        init() {
            self.peripheralManager = BPPeripheralManager()
        }
        
        deinit {
            print("builder deinit")
        }
    }
}

extension BP.Builder {
    public func advertise(_ advertisementData: [String: Any]?) {
        self.peripheralManager.advertise(advertisementData: advertisementData)
    }
    
    @discardableResult
    public func service(_ build: (BPServiceBuilder) -> Void) -> Self {
        self.peripheralManager.service(build)
        return self
    }
}
