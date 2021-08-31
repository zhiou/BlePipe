import CoreBluetooth

public typealias BPWillStartScanClosure = () -> Void
public typealias BPDidStopScanClosure = (BPError?) -> Void

public class BPScanner {

    private var  cm: CBCentralManager
    
    private let delegateProxy: BPCentralManagerDelegateProxy = BPCentralManagerDelegateProxy()
    
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
    
    public var didStop: BPDidStopScanClosure?
    public var willStart: BPWillStartScanClosure?
    
    public init(centralManager: CBCentralManager) {
        cm = centralManager
        delegateProxy.stateClosure = { [unowned self] state in
            switch state {
            case .poweredOn:
                self.task?()
            default:
                self.task = nil
            }
        }
        cm.delegate = delegateProxy
    }
    
    deinit {
        print("deinit")
    }
    
    
    public func start() {
        startWith(duration: 0)
    }
    
    
    public func startWith(duration: TimeInterval) {
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
        
        willStart?()
        cm.scanForPeripherals(withServices: nil, options: nil)
        if duration > 0 {
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] timer in
                self?.endScan(.timeout)
            })
        }
    }
    
    public func stop() {
       endScan(nil)
    }
    
    private func endScan(_ error: BPError?) {
        self.timer?.invalidate()
        self.timer = nil
        self.cm.stopScan()
        self.didStop?(error)
    }
}
