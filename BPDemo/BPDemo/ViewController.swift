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

class ViewController: UITableViewController {
    
    let bp = BPScanner()

    let central = BPCentral()
    
    var discoveries: [BPDiscovery] = []
    var peripherals: [BPRemotePeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bp.filterClosure = { discovery in
            return discovery.displayName != "Unkown Name"
        }
        
        bp.discoverClosure = { [unowned self] discovery in
            print("1 --- :" + discovery.displayName)
            if !discoveries.contains(discovery) {
                discoveries.append(discovery)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

        }
        bp.willStart = { [weak self] in
            self?.discoveries = []
            self?.tableView.reloadData()
        }
        bp.didStop = { error in
            print("stop discover")
        }
        bp.startWith(duration: 10)
    }
    
    @IBAction func refresh(_ sender: Any) {
 
        bp.startWith(duration: 10)
    }
}

extension ViewController/*: UITableViewDataSource */{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "discovery")
        cell.textLabel?.text = discoveries[indexPath.row].displayName;
        return cell;
    }
}

extension ViewController/*: UITableViewDelegate */{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let discovery = discoveries[indexPath.row]
        self.central.connect(discovery.remote) { [unowned self] remotePeripheral, error in
            if let error = error {
                print(error)
                return
            }
            if let rp = remotePeripheral, !peripherals.contains(rp) {
                peripherals.append(rp)
            }
        }
    }
}
