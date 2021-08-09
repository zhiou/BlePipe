//
//  ViewController.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/9.
//

import UIKit
import BlePipe

class ViewController: UIViewController {
    
    let bp = BPScanner()
    
    let bp2 = BPScanner()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bp.discoverClosure = { discovery in
            print("1 --- :" + discovery.displayName)
        }
        
        bp2.discoverClosure = { discovery in
            print("2 --- :" + discovery.displayName)
        }

        bp.start()
        
        bp2.start()
      
    }
    
    
    


}

