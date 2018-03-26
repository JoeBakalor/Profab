//
//  NetworkScanDataModel.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/11/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import Foundation

enum ConnectionStatus{
    case connected
    case disconnected
}

class NetworkScanDataModel: NSObject{
    
    public struct SsidScanUIDelegate {
        var updateHandler = {(newSSID: String) in}
        var connectedHandler = {() in}
    }
    
    public struct NetworkScanUIDelegate{
        var scanResultHandler = {(newSSID: String) in}
        var connectionStatusHandler = {(connectionStatus: ConnectionStatus) in}
    }
    
    fileprivate var ssidScanUIDelegate: SsidScanUIDelegate!
    fileprivate var networkScanUIDelegate: NetworkScanUIDelegate?
    
    init(scanResultHander: SsidScanUIDelegate) {
        super.init()
        ssidScanUIDelegate = scanResultHander
        wifiIntroManager.setScanResultDelegate(delegate: self)
    }
}

//MARK: VIEW CONTROLLER ACCESS METHODS
extension NetworkScanDataModel{
    
    func startApScan(){
        wifiIntroManager.scanForAccessPoints()
    }
    
    func stopApScan(){
        wifiIntroManager.stopScanningForAccessPoints()
    }
    
    func connectToAp(ssid: String, password: String){
        wifiIntroManager.connectToAccessPoint(ssid: ssid, passphrase: password)
    }
}

extension NetworkScanDataModel: ScanResultDelegate{
    
    func foundNewAccessPoint(ssid: String) {
        print("Found New AP \(ssid)")
        ssidScanUIDelegate.updateHandler(ssid)
    }
    
    func connectedToAP() {
        ssidScanUIDelegate.connectedHandler()
        networkScanUIDelegate?.connectionStatusHandler(ConnectionStatus.connected)
    }
    
    func disconnectedFromAP() {
        
    }
    
}

