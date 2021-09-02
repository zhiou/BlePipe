//
//  TransmitViewController.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/18.
//

import BlePipe
import UIKit
import CommonCrypto

extension BPPacketProcessor {
    func check(buffer: Data, frame: Data) -> Data? {
        if frame == "EOD".data(using: .utf8) {
            return buffer
        }
        return nil
    }
}

class TransmitViewController: UIViewController {
    @IBOutlet weak var logView: UITextView!
    
    private var log: String = ""
    var discovery: BPDiscovery? = nil
    var peripherals: [BPRemotePeripheral] = []
    
    let endUUID = "477A2967-1FAB-4DC5-920A-DEE5DE685A3D"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BP.centralManager
            .service([])
            .port(endUUID)
            .build(discovery!.remote.identifier) { result in
                let _ = result.map { [unowned self] rp in
                    self.peripherals.append(rp)
                    if let end = rp[endUUID] {
                        end.recv { result in
                            if let data = try? result.get() {
                                self.log.append("recv \(data.count)B, hash(\(data.md5))\n")
                                DispatchQueue.main.async {
                                    self.logView.text = self.log
                                }
                            }
                        }
                    }
                }
            }
    }
    
    @IBAction func send(_ sender: Any) {
            sendRandomPacket()
    }
    
    private func sendRandomPacket() {
        if let rp = peripherals.first {
            let numberOfBytesToSend: Int = Int(arc4random() % 0x800)
            let data = Data.dataWithNumberOfBytes(numberOfBytesToSend)
            let endMark = "EOD".data(using: .utf8)!
            if let end = rp[endUUID] {
                end.send(data)
                end.send(endMark)
            }
            log.append(contentsOf: "send \(data.count)B, hash(\(data.md5))\n")
            logView.text = log
        }
    }
}

extension Data {
    
    static func dataWithNumberOfBytes(_ numberOfBytes: Int) -> Data {
        let data:[UInt8] = (0..<numberOfBytes).map { _ in
            return UInt8(arc4random() % 0xFF)
        }
        return Data(data)
    }
    
    var md5:String {
        var md5 = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        let unsafe = [UInt8](self)
        let length = CC_LONG(self.count)
  
        CC_MD5(unsafe, length, &md5)
        return md5.reduce(""){ $0 + String(format:"%02X", $1) }
    }
    
}
