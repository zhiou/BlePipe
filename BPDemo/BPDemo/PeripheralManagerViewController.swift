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
    override func viewDidLoad() {
        super.viewDidLoad()
        BP.peripheralManager()
            .service { service in
                service.uuidString("1234-3211-1111-1111")
                    .primary(true)
                    .characteristic { characteristic in
                        characteristic.uuidString("1234-3211-1111-1112")
                            .properties([ .read, .notify, .writeWithoutResponse, .write ])
                            .permissions ([ .readable, .writeable ])
                    }
            }
            .service { service in
                service.uuidString ("1234-3211-1111-1112")
                    .primary(true)
            }
            .advertise(nil)
    }
}
