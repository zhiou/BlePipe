//
//  TransmitViewController.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/18.
//

import BlePipe
import UIKit
import CommonCrypto

class TransmitViewController: UIViewController {
    @IBOutlet weak var logView: UITextView!
    
    private var log: String = ""
    var discovery: BPDiscovery? = nil
    var peripherals: [BPRemotePeripheral] = []
    
    let endUUID = "477A2967-1FAB-4DC5-920A-DEE5DE685A3D"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        discovery?.remote.bp.build(remoteEnds: [endUUID]) { result in
            let _ = result.map { [unowned self] rp in
                self.peripherals.append(rp)
                if let end = rp[endUUID] {
                    end.subscribe { data, error in
                        if let error = error {
                            print(error)
                            return
                        }
                        if let data = data {
                            self.log.append("recv \(data.count)B, hash(\(data.md5))")
                            self.logView.text = log
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func send(_ sender: Any) {
        for _ in 1 ..< 10 {
            sendRandomPacket()
        }
    }
    
    private func sendRandomPacket() {
        if let rp = peripherals.first {
            let numberOfBytesToSend: Int = Int(arc4random() % 520 + 50)
            let data = Data.dataWithNumberOfBytes(numberOfBytesToSend)
            let endMark = "EOD".data(using: .utf8)!
            if let end = rp[endUUID] {
                try? end.write(data: data)
                try? end.write(data: endMark)
            }
            print(data.base64EncodedString())
            log.append(contentsOf: "send \(data.count)B, hash(\(data.md5))")
            logView.text = log
        }
    }
}


extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}

extension Data {
    
    static func dataWithNumberOfBytes(_ numberOfBytes: Int) -> Data {
        let bytes = malloc(numberOfBytes)
        let data = Data(bytes: bytes!, count: numberOfBytes)
        free(bytes)
        return data
    }
    
    var md5:String {
        return withUnsafePointer(to: UInt8.self, { p in
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(p, CC_LONG(self.count), &digest)
            return digest.reduce("") { $0 + String(format:"%02X", $1) }
        })
    }
    
}
