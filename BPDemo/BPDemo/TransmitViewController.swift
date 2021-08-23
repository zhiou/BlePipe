//
//  TransmitViewController.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/18.
//

import BlePipe
import UIKit

class TransmitViewController: UIViewController {
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
                        print(data)
                        end.write(data: data!) { error in
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func send(_ sender: Any) {
        if let rp = peripherals.first {
            let numberOfBytesToSend: Int = 10
            let data = Data.dataWithNumberOfBytes(numberOfBytesToSend)
            let endMark = "EOD".data(using: .utf8)!
            if let end = rp[endUUID] {
                end.write(data: data) { error in
                    print(error)
                }
                end.write(data: endMark) { error in
                    print(error)
                }
            }
        }
    }
}



extension Data {

    static func dataWithNumberOfBytes(_ numberOfBytes: Int) -> Data {
        let bytes = malloc(numberOfBytes)
        let data = Data(bytes: bytes!, count: numberOfBytes)
        free(bytes)
        return data
    }

}
