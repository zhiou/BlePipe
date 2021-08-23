//
//  CBPeripheral+BluePipe.swift
//  CBPeripheral+BluePipe
//
//  Created by zhiou on 2021/8/23.
//

import CoreBluetooth

public typealias BPBuildPipeCompletionHandler = (Result<BPRemotePeripheral, BPError>) -> Void

extension BluePipeWrapper where Base: CBPeripheral {
    public func build(remoteEnds: [String], completionHandler: @escaping BPBuildPipeCompletionHandler) {
        guard let centralManager = base.bp.discoverer else {
            completionHandler(Result.failure(.unkownDevice))
            return
        }
//        let dataServiceCharacteristicUUID = CBUUID(string: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")
        let cuuids = remoteEnds.map(CBUUID.init(string:))
        let config = BPConfiguration(serviceUUIDs: [], allowDuplicates: false, pipeEndUUIDs: cuuids)
        let cm = BPCentralManager(centralManager: centralManager, config: config)
  
        cm.connect(base) { peripheral, error in
            if let error = error {
                completionHandler(Result.failure(error))
                return
            }
            if let p = peripheral {
                completionHandler(Result.success(p))
            }
        }
    }
}





private var peripheralDiscovererKey: Void?

extension BluePipeWrapper where Base: CBPeripheral {
    var discoverer: CBCentralManager? {
        get { return objc_getAssociatedObject(base, &peripheralDiscovererKey) as? CBCentralManager }
        set { objc_setAssociatedObject(base, &peripheralDiscovererKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
