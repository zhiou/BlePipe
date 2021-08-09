import CoreBluetooth


public typealias BPCompletionClosure = (BPError?) -> Void

public class BPScanner {

    private var cm: CBCentralManager {
        get {
            return CBCentralManager(delegate: delegateProxy, queue: nil, options: nil)
        }
    }
    
    private let delegateProxy: BPCentralManagerDelegateProxy = BPCentralManagerDelegateProxy()
    
    private var configuration: BPConfiguration?
    
    private var timer: Timer?
    
    private var task: (() -> Void)?
    
    public var discoverClosure: BPDiscoveredClosure? {
        get {
            return delegateProxy.discoverdClosure
        }
        set {
            delegateProxy.discoverdClosure = newValue
        }
    }
    
    public var filterClosure: BPFilterClosure? {
        get {
            return delegateProxy.filterClosure
        }
        set {
            delegateProxy.filterClosure = newValue
        }
    }
    
    public var completionClosure: BPCompletionClosure?
    
    init() {
        delegateProxy.stateClosure = { [unowned self] state in
            switch state {
            case .poweredOn:
                self.task?()
            default:
                self.task = nil
            }
        }
    }
    
    
    //TODO: may be stuck in main thread
    static func scan(for displayName: String, in seconds: Int) -> BPDiscovery? {
        let scanner = BPScanner()
        var result: BPDiscovery? = nil
        let sem = DispatchSemaphore(value: 0)
        scanner.filterClosure = {
            return $0.displayName == displayName
        }
        scanner.discoverClosure = { discovery in
            result = discovery
            sem.signal()
        }
        scanner.completionClosure = { error in
            sem.signal()
        }
        scanner.startWith(duration: TimeInterval(seconds))
        
        sem.wait()
        return result
    }
    
    func start() {
        startWith(duration: 0)
    }
    
    
    func startWith(duration: TimeInterval) {
        if cm.isScanning {
            return
        }
        
        if cm.state != .poweredOn {
            task = { [unowned self] in
                self.startWith(duration: duration)
                self.task = nil
            }
            return
        }
        
        var options: [String: Any]? = nil
        if let allowDuplicates = configuration?.allowDuplicates {
            options = [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates]
        }
        cm.scanForPeripherals(withServices: configuration?.serviceUUIDs, options: options)
        if duration > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [unowned self] timer in
                self.endScan(.timeout)
            })
        }
    }
    
    func stop() {
       endScan(nil)
    }
    
    private func endScan(_ error: BPError?) {
        self.timer?.invalidate()
        self.timer = nil
        self.cm.stopScan()
        self.completionClosure?(error)
    }
}
