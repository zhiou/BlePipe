//
//  BluePipe.swift
//  BluePipe
//
//  Created by zhiou on 2021/8/23.
//

import Foundation
import CoreBluetooth

public struct BluePipeWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BluePipeCompatible: AnyObject {}

public protocol BluePipeCompatibleValue {}

extension BluePipeCompatible {
    public var bp: BluePipeWrapper<Self> {
        get { return BluePipeWrapper(self) }
        set { }
    }
}

extension BluePipeCompatibleValue {
    public var bp: BluePipeWrapper<Self> {
        get { return BluePipeWrapper(self) }
        set { }
    }
}

extension CBCentralManager: BluePipeCompatible { }

extension CBPeripheral: BluePipeCompatible { }

extension CBPeripheralManager: BluePipeCompatible { }

extension CBCentral: BluePipeCompatible { }
