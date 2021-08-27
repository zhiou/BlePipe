//
//  PeripheralManagerView.swift
//  PeripheralManagerView
//
//  Created by zhiou on 2021/8/26.
//

import UIKit
import BlePipe
import CoreBluetooth

class PeripheralManagerViewController: UIViewController {
    private var log: String = ""
    
    @IBOutlet weak var logView: UITextView!
    
    private var ports:[BPPort] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BP.peripheralManager()
            .onPortBuilt({ port in
                self.ports.append(port)
                port.onWrite { data, error in
                    if let error = error {
                        print(error)
                    } else if let data = data{
                        print("to be notify \(data)")
                        self.log.append(contentsOf: "recv \(data.count)B, hash(\(data.md5))\n")
                        DispatchQueue.main.async {
                            self.logView.text = self.log
                        }
                        try? port.notify(data: data)
                        try? port.notify(data: "EOD".data(using: .utf8)!)
                    }
                }
            })
            .service { service in
                service.uuidString("6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")
                    .primary(true)
                    .characteristic { characteristic in
                        characteristic.uuidString("477A2967-1FAB-4DC5-920A-DEE5DE685A3D")
                            .properties([ .read, .notify, .writeWithoutResponse, .write ])
                            .permissions ([ .readable, .writeable ])
                    }
            }.advertise([CBAdvertisementDataLocalNameKey: "BPDemo"])
    }
    
    @IBAction func sendData(_ sender: Any) {
        sendRandomPacket()
    }
    
    private func sendRandomPacket() {
        if let port = ports.first {
            let numberOfBytesToSend: Int = Int(arc4random() % 0x800)
            let data = Data.dataWithNumberOfBytes(numberOfBytesToSend)
            let endMark = "EOD".data(using: .utf8)!
            try? port.notify(data: data)
            try? port.notify(data: endMark)
            log.append(contentsOf: "send \(data.count)B, hash(\(data.md5))\n")
            logView.text = log
        }
    }
    
}
