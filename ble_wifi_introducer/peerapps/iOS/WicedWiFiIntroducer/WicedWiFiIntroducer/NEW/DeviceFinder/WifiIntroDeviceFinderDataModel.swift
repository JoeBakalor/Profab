//
//  WifiIntroDeviceFinderDataModel.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/12/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import Foundation

protocol DeviceDiscoveryDelegate {
    func foundDevice()
    func attemptingConnectionToDevice()
    func connectedToDevice()
    func connectionFailed()
    func ready()
}

class WifiIntroDeviceFinderDataModel: NSObject{
    
    var deviceDiscoveryDelegate: DeviceDiscoveryDelegate?
    
    init(delegate: DeviceDiscoveryDelegate) {
        super.init()
        deviceDiscoveryDelegate = delegate
        wifiIntroManager.setWifiIntroDelegate(delegate: self)
    }
    
    func startDiscovery(){
        wifiIntroManager.findWiFiIntroducer()
    }
    
    func connectToDevice(){
        wifiIntroManager.connectToWiFiIntroducer()
    }
}

extension WifiIntroDeviceFinderDataModel: WifiIntroDelegate, WifiIntroducerDelegate{
    
    func ready() {
         
    }
    
    func wifiIntroducerDeviceConnectionFailed() {
        
    }
    
    func radioReady() {
        
        deviceDiscoveryDelegate?.ready()//radioReady()
    }
    
    func connectedToWifiIntroDevice() {
        
        deviceDiscoveryDelegate?.connectedToDevice()
    }
    
    func wifiIntroDeviceConnectionFailed() {
        
        deviceDiscoveryDelegate?.connectionFailed()
    }
    
    func foundWifiIntroducer() {
        
        deviceDiscoveryDelegate?.foundDevice()
    }
    
    
}
