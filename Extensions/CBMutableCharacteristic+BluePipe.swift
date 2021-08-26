//
//  CBMutableCharacteristic+BluePipe.swift
//  CBMutableCharacteristic+BluePipe
//
//  Created by zhiou on 2021/8/26.
//

import CoreBluetooth


extension BluePipeWrapper where Base: CBMutableCharacteristic {
    public func make(_ uuidString: String, properties: CBCharacteristicProperties, value: Data?, permissions: CBAttributePermissions) -> CBMutableCharacteristic {
        let uuid = CBUUID(string: uuidString)
        return CBMutableCharacteristic(type: uuid, properties: properties, value: value, permissions: permissions)
    }
}
