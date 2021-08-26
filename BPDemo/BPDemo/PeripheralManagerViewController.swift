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
    var builder: BP.Builder? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        builder = BP.peripheralManager()
            .service { service in
                service.uuidString("6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")
                    .primary(true)
                    .characteristic { characteristic in
                        characteristic.uuidString("477A2967-1FAB-4DC5-920A-DEE5DE685A3D")
                            .properties([ .read, .notify, .writeWithoutResponse, .write ])
                            .permissions ([ .readable, .writeable ])
                    }
            }
        builder?.advertise([CBAdvertisementDataLocalNameKey: "BPDemo"])
    }
}
