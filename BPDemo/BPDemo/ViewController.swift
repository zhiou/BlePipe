//
//  ViewController.swift
//  BPDemo
//
//  Created by zhiou on 2021/8/9.
//

import UIKit
import BlePipe
import CoreBluetooth

//extension BPDiscovery {
//    var displayName: String {
//        return self.remote.name ?? ""
//    }
//}

///
/// CBCentralManager.bp.target(?name regular?)
///     .just(10)/untilTimeout))
///     .timeout(10)
///     .scan { peripheral in
///
///         let pipe = peripheral.bp.build(name: String, writeEnd: CBUUID, recvEnd: CBUUID)
///         pipe
///         .send(data)
///         .notify { recv in
///             print(recv)
///         }
///         pip.notify { recv in
///             print(recv)
///         }
/// }
///

class ViewController: UITableViewController {
    
    let centralManager = CBCentralManager(delegate: nil, queue: nil)
    
    var discoveries: [BPDiscovery] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        start()
    }
    
    @IBAction func refresh(_ sender: Any) {
        start()
    }
    
    private func start() {
        centralManager.bp
            .timeout(10)
            .filter { discovery in
                return discovery.displayName != "Unkown Name"
            }
            .just(.untilTimeout)
            .willStartScan { [unowned self] in
                self.discoveries = []
                self.tableView.reloadData()
            }
            .didStopScan {
                print("stop discover")
            }
            .scan { [unowned self] discovery in
                print("1 --- :" + discovery.displayName)
                if !discoveries.contains(discovery) {
                    discoveries.append(discovery)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
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
        self.performSegue(withIdentifier: "Transmit", sender: tableView.cellForRow(at:indexPath))
     
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TransmitViewController,
        let cell = sender as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell) {
            vc.discovery = discoveries[indexPath.row]
        }
    }
}
