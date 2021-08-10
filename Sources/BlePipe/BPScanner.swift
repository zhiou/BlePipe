import CoreBluetooth


public typealias BPCompletionClosure = (BPError?) -> Void

public class BPScanner {

    private lazy var  cm: CBCentralManager = CBCentralManager(delegate: delegateProxy, queue: nil, options: nil)
    
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
    
    public init() {
        delegateProxy.stateClosure = { [unowned self] state in
            switch state {
            case .poweredOn:
                self.task?()
            default:
                self.task = nil
            }
        }
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
        
        var options: [String: Any]? = nil
        if let allowDuplicates = configuration?.allowDuplicates {
            options = [CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates]
        }
        
        cm.scanForPeripherals(withServices: configuration?.serviceUUIDs, options: options)
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
        self.completionClosure?(error)
    }
}
