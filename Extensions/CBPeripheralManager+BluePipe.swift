//
//  CBPeripheralManager+BluePipe.swift
//  CBPeripheralManager+BluePipe
//
//  Created by zhiou on 2021/8/26.
//

import CoreBluetooth


extension BluePipeWrapper where Base: CBPeripheralManager {
    

   
}

private var peripheralManagerKey: Void?

extension BluePipeWrapper where Base: CBPeripheralManager {
    
    var peripheralManager: BPPeripheralManager? {
        get {
            if let pm = objc_getAssociatedObject(base, &peripheralManagerKey) as? BPPeripheralManager {
                return pm
            } else {
                let pm = BPPeripheralManager()
                objc_setAssociatedObject(base, &peripheralManagerKey, pm, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return pm
            }
        }
    }
}
