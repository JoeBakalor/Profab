//
//  WifiIntroDeviceFinderViewController.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/12/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import UIKit

class WifiIntroDeviceFinderViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var deviceFinderDataModel: WifiIntroDeviceFinderDataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceFinderDataModel = WifiIntroDeviceFinderDataModel(delegate: self)
        activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func connectButton(_ sender: UIButton) {
        activityIndicator.isHidden = false
        deviceFinderDataModel.connectToDevice()
    }
    

}

extension WifiIntroDeviceFinderViewController: DeviceDiscoveryDelegate{
    
    func ready(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        statusLabel.text = "Searching"
        deviceFinderDataModel.startDiscovery()
    }
    
    func foundDevice() {
        activityIndicator.isHidden = true
        statusLabel.text = "Found Device"
    }
    
    func attemptingConnectionToDevice() {
        statusLabel.text = "Attempting to Connect"
    }
    
    func connectedToDevice() {
        
        activityIndicator.isHidden = true
        statusLabel.text = "Connected to Device"
        
        //SETUP TRANSISTION TO TAB VIEW CONTROLLER
        let transistion = CATransition()
        transistion.subtype = kCATransitionReveal
        view.window!.layer.add(transistion, forKey: kCATransition)
        let newView = self.storyboard?.instantiateViewController(withIdentifier: "newtworkScanViewController") as! NetworkScanViewController
        
        //TRANSISTION TO VIEW CONTROLLER
        self.navigationController?.show(newView, sender: self)
    }
    
    func connectionFailed() {
         
    }
    
    
}
