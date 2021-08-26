//
//  CBMutableService+BluePipe.swift
//  CBMutableService+BluePipe
//
//  Created by zhiou on 2021/8/26.
//

import CoreBluetooth


extension BluePipeWrapper where Base: CBMutableService {
    public func make(_ uuidString: String, primary: Bool) -> CBMutableService {
        let uuid = CBUUID(string: uuidString)
        let service = CBMutableService(type: uuid, primary: primary)
        if let characteristics = self.characteristics {
            service.characteristics?.append(contentsOf: characteristics)
        }
        return service
    }
    
    public func add(_ characteristic: CBMutableCharacteristic) -> Self {
        var mutatingSelf = self
        if var characteristics = self.characteristics {
            if !characteristics.contains(characteristic) {
                characteristics.append(characteristic)
            }
            mutatingSelf.characteristics = characteristics
        } else {
            mutatingSelf.characteristics = [characteristic]
        }
        return self
    }
}

private var characteristicsKey: Void?

extension BluePipeWrapper where Base: CBMutableService {
    var characteristics: [CBMutableCharacteristic]? {
        get { objc_getAssociatedObject(base, &characteristicsKey) as? [CBMutableCharacteristic] }
        set { objc_setAssociatedObject(base, &characteristicsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
