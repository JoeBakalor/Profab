//
//  NetworkScanViewController.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/9/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import UIKit
let up = true
let down = false
typealias UpOrDown = Bool
class NetworkScanViewController: UIViewController {

    enum ScanState{
        case scanning
        case stopped
    }

    
    var scanState = ScanState.stopped
    var networkScanDataModel: NetworkScanDataModel!
    var ssidResults: [String] = []
    var radioReady = false
    var ssid = ""
    
    @IBOutlet weak var scanResultTableView: UITableView!
    @IBOutlet weak var scanningActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let scanHandler =  { (ssid: String) in
            if ssid.count > 2{
                self.ssidResults.append(ssid)
                self.scanResultTableView.reloadData()
            }
        }
        
        let successHandler = {() -> () in
            let connectionConfirmationAlert = UIAlertController(title: "\(self.ssid)", message: "Connection Succeeded", preferredStyle: .alert)
            connectionConfirmationAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(UIAlertAction) in
                self.animateTable(upOrDown: up)
            }))
            
            self.present(connectionConfirmationAlert, animated: true)
        }
            
        let scanResultHandler = NetworkScanDataModel.SsidScanUIDelegate(updateHandler: scanHandler, connectedHandler: successHandler)
        networkScanDataModel = NetworkScanDataModel(scanResultHander: scanResultHandler)
        
    }
    
    
    @IBAction func scanStartButton(_ sender: UIButton) {
        
        guard scanState == .stopped else {return}
        scanState = .scanning
        animateTable(upOrDown: down)
        networkScanDataModel.startApScan()
    }
    
    
    @IBAction func scanStopButton(_ sender: UIButton) {
        
        guard scanState == .scanning else { return }
        scanState = .stopped
        animateTable(upOrDown: up)
        networkScanDataModel.stopApScan()
    }
    
    func animateTable(upOrDown: UpOrDown){
        
        if upOrDown{
            scanningActivityIndicator.stopAnimating()
            self.topConstraint.constant -= 50
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            scanningActivityIndicator.startAnimating()
            self.topConstraint.constant += 50
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
}

//MARK: UITableViewDataSource
extension NetworkScanViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ssidResults.count//ssidTestResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = scanResultTableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        cell.textLabel?.text = ssidResults[indexPath.row]//ssidTestResults[indexPath.row].ssid
        cell.detailTextLabel?.text = ""//RSSI: \(ssidTestResults[indexPath.row].signalStrength)"
        
        return cell
    }
    
}

//MARK: UITableViewDelegate
extension NetworkScanViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.scanStopButton(UIButton())
        let ssidSelected = ssidResults[indexPath.row]
        let connectionConfirmationAlert = UIAlertController(title: "\(ssidResults[indexPath.row])", message: "Please Enter Password", preferredStyle: .alert)
        
        connectionConfirmationAlert.addTextField(configurationHandler: {(passphrase) in passphrase.text = "Password"})
        
        connectionConfirmationAlert.addAction(UIAlertAction(title: "CONNECT", style: .destructive, handler: {[weak connectionConfirmationAlert] (_) in
            let password = connectionConfirmationAlert?.textFields![0]
            print("Connect To \(ssidSelected)")
            self.ssidResults = []
            self.scanResultTableView.reloadData()
            
            self.animateTable(upOrDown: down)
            self.networkScanDataModel.connectToAp(ssid: ssidSelected, password: password!.text!)
            self.ssid = ssidSelected
        }))
        
        connectionConfirmationAlert.addAction(UIAlertAction(title: "CANCEL", style: .destructive, handler: nil))
        self.present(connectionConfirmationAlert, animated: true, completion: nil)
    }
}


