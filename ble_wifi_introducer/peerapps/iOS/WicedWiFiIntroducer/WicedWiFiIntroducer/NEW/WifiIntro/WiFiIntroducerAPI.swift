//
//  WiFiIntroducerAPI.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/12/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import Foundation

enum WifiIntroDeviceStatus {
    case unknown
    case connected
    case pendingConnection
    case disconnected
}

enum WifiIntroducerDeviceStatus {
    case unknown
    case connected
    case pendingConnection
    case disconnected
    case scanning
    case idle
}

protocol WifiIntroducerAPI{
    
    //DEVICE CONNECTION AND DISCOVERY
    func findWiFiIntroducer()
    func connectToWiFiIntroducer()
    func disconnectWiFiIntroducer()
    
    //ACCESS POINT DISCOVERY
    func scanForAccessPoints()
    func stopScanningForAccessPoints()
    func connectToAccessPoint(ssid: String, passphrase: String)
    func disconnectFromAcessPoint()
    
    //STATUS
    var status: WifiIntroducerDeviceStatus {get}
}
