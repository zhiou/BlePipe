//
//  ViewController.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/9.
//

import UIKit
import BlePipe

//extension BPDiscovery {
//    var displayName: String {
//        return self.remote.name ?? ""
//    }
//}

class ViewController: UIViewController {
    
    let bp = BPScanner()
    
//    let bp2 = BPScanner()
    let central = BPCentral()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bp.filterClosure = { discovery in
            return discovery.displayName != "Unkown Name"
        }
        
        bp.discoverClosure = { [weak self] discovery in
            print("1 --- :" + discovery.displayName)
            self?.central.connect(peripheral: discovery.remote) { remotePeripheral, error in
                print(remotePeripheral)
                print(error)
            }
        }
        
//        bp2.discoverClosure = { discovery in
//            print("2 --- :" + discovery.displayName)
//        }

        bp.start()
        
//        bp2.start()
      
    }
    
    
    


}

