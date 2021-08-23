//
//  CBCentralManager+BluePipe.swift
//  CBCentralManager+BluePipe
//
//  Created by zhiou on 2021/8/23.
//

import CoreBluetooth
import UIKit

public enum ScanStrategy {
    case take(n: Int)
    case untilTimeout
}

public typealias BPScanFilter = (BPDiscovery) -> Bool
public typealias BPScanBlock = (BPDiscovery) -> Void
public typealias BPScanCompletionHandler = (BPError?) -> Void

public typealias BPWillStartScanBlock = () -> Void
public typealias BPDidStopScanBlock = () -> Void

public typealias BPFindBlock = (Result<BPDiscovery, BPError>) -> Void

extension BluePipeWrapper where Base: CBCentralManager {
    
    public func just(_ strategy: ScanStrategy) -> Self {
        var mutatingSelf = self
        mutatingSelf.scanStrategy = strategy
        return self
    }
    
    public func timeout(_ timeout: Int) -> Self {
        var mutatingSelf = self
        mutatingSelf.timeout = timeout
        return self
    }
    
    public func filter(_ filter: @escaping BPScanFilter) -> Self {
        var mutatingSelf = self
        mutatingSelf.filter = filter
        return self
    }
    
    public func willStartScan(_ block: @escaping BPWillStartScanBlock) -> Self {
        var mutatingSelf = self
        mutatingSelf.willStartScan = block
        return self
    }
    
    public func didStopScan(_ block: @escaping BPDidStopScanBlock) -> Self {
        var mutatingSelf = self
        mutatingSelf.didStopScan = block
        return self
    }
    
    public func scan(_ scanBlock: @escaping BPScanBlock, completionHandler: BPScanCompletionHandler? = nil) {
        var mutatingSelf = self
        let scanner = BPScanner(centralManager: base)
        scanner.discoverClosure = { discovery in
            scanBlock(discovery)
            if let count = mutatingSelf.count {
                mutatingSelf.count = count + 1
                if case .take(let n) = mutatingSelf.scanStrategy, n == count
                {
                    scanner.stop()
                }
            }
        }
        if let filter = mutatingSelf.filter {
            scanner.filterClosure = filter
        }
        scanner.didStop = { error in
            completionHandler?(error)
        }
        if let timeout = self.timeout {
            let ti = TimeInterval(timeout)
            scanner.startWith(duration: ti)
        } else {
            scanner.start()
        }
        mutatingSelf.scanner = scanner
    }
    
    public func find(_ displayName: String, block: @escaping BPFindBlock) {
        let predicate = NSPredicate(format: "SELF MATCHES %@", displayName)
        self.filter { discovery in
            return predicate.evaluate(with: discovery.displayName)
        }
        .scan { discovery in
            block(Result.success(discovery))
        } completionHandler: { error in
            if let error = error {
                block(Result.failure(error))
            }
        }
    }
}

private var scanStrategyKey: Void?
private var timeoutKey: Void?
private var countKey: Void?
private var scannerKey: Void?
private var filterKey: Void?
private var willStartScanKey: Void?
private var didStopScanKey: Void?

extension BluePipeWrapper where Base: CBCentralManager {
    var scanStrategy: ScanStrategy? {
        get { return objc_getAssociatedObject(base, &scanStrategyKey) as? ScanStrategy}
        set { objc_setAssociatedObject(base, &scanStrategyKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    var timeout: Int? {
        get { return objc_getAssociatedObject(base, &timeoutKey) as? Int}
        set { objc_setAssociatedObject(base, &timeoutKey, newValue, .OBJC_ASSOCIATION_ASSIGN)}
    }
    
    var count: Int? {
        get { return objc_getAssociatedObject(base, &countKey) as? Int}
        set { objc_setAssociatedObject(base, &countKey, newValue, .OBJC_ASSOCIATION_ASSIGN)}
    }
    
    var scanner: BPScanner? {
        get { return objc_getAssociatedObject(base, &scannerKey) as? BPScanner}
        set { objc_setAssociatedObject(base, &scannerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    var filter: BPScanFilter? {
        get { return objc_getAssociatedObject(base, &filterKey) as? BPScanFilter}
        set { objc_setAssociatedObject(base, &filterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    var willStartScan: BPWillStartScanBlock? {
        get { return objc_getAssociatedObject(base, &willStartScanKey) as? BPWillStartScanBlock}
        set { objc_setAssociatedObject(base, &willStartScanKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    var didStopScan: BPDidStopScanBlock? {
        get { return objc_getAssociatedObject(base, &didStopScanKey) as? BPDidStopScanBlock}
        set { objc_setAssociatedObject(base, &didStopScanKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
}
