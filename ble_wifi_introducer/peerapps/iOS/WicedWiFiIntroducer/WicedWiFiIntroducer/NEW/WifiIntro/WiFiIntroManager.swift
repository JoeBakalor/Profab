//
//  WiFiIntroManager.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/12/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import Foundation
import CoreBluetooth

var wifiIntroManager = WiFiIntroManager()//(bleStatusDelegate: nil)
let gattProfile = GATT()

protocol ScanResultDelegate {
    func foundNewAccessPoint(ssid: String)
    func connectedToAP()
    func disconnectedFromAP()
}

protocol WifiIntroDelegate {
    func foundWifiIntroducer()
    func wifiIntroDeviceConnectionFailed()
    func connectedToWifiIntroDevice()
    func radioReady()
    func ready()
}

protocol APConnectionManagerDelegate{
    func foundNewAP(ssid: String)
    func connectedToAP()
    func disconnectedFromAP()
}

protocol WifiIntroducerDelegate{
    func foundWifiIntroducer()
    func wifiIntroducerDeviceConnectionFailed()
    func connectedToWifiIntroDevice()
    func ready()
}

class WiFiIntroManager: BLETopLevelController{
    
    var bleReady = false
    var scanResultDelegate: ScanResultDelegate?
    var wifiIntroDevice: CBPeripheral?
    var wifiIntroDelegate: WifiIntroDelegate?
    
    var wifiIntroducerDeviceStatus = WifiIntroducerDeviceStatus.idle
    var wifiIntroducerDevice: CBPeripheral?
    var wifiIntroducerDelegate: WifiIntroducerDelegate?
    var apConnectionManagerDelegate: APConnectionManagerDelegate?
    
    public var status: WifiIntroducerDeviceStatus{
        return wifiIntroducerDeviceStatus
    }
    
    init(){
        super.init(bleStatusDelegate: self, _gattDelegate: gattProfile as GattDelegate, _peripheralDiscoveryDelegate: self)
        super.setConnectionDelegate(delegate: self)
        gattProfile.setCharUpdateDelegate(delegate: self)
    }
    
    func setAPConnectionManagerDelegate(_apConnectionManagerDelegate: APConnectionManagerDelegate){
        self.apConnectionManagerDelegate = _apConnectionManagerDelegate
    }
    
    func setScanResultDelegate(delegate: ScanResultDelegate){
        scanResultDelegate = delegate
    }
    
    func setWifiIntroDelegate(delegate: WifiIntroDelegate){
        wifiIntroDelegate = delegate
    }
}

extension WiFiIntroManager: CharValueUpdateDelegate{
    
    
    func newValue(forCharacteristic characteristic: WiFiIntroChars, value: Any) {
        
        switch characteristic {
        case .scanResult:
            
            print("WiFiIntroManager: Found new AP")
            apConnectionManagerDelegate?.foundNewAP(ssid: value as! String)
            scanResultDelegate?.foundNewAccessPoint(ssid: value as! String)
            return

        case .notify:
            
            apConnectionManagerDelegate?.connectedToAP()
            scanResultDelegate?.connectedToAP()
            return
            
        case .passphrase:
            
            return
            
        case .security:
            
            return
            
        case .ssid:
            
            return
            
        default:
            
            return
        }
    }
}

extension WiFiIntroManager: WifiIntroducerAPI{
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func getWifiIntroDeviceStatus() -> WifiIntroducerDeviceStatus {
        return wifiIntroducerDeviceStatus
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func findWiFiIntroducer() {
        super.startScanningForPeripherals(withServices: [WIFI_INTRODUCER_SERVICE_UUID])
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func connectToWiFiIntroducer() {
        if let peripheral = wifiIntroDevice{
            super.connect(toPeripheral: peripheral, withTimeout: 5)
        }
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func disconnectWiFiIntroducer() {
        if let peripheral = wifiIntroDevice{
            super.disconnect()
        }
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func scanForAccessPoints() {
        //SEND SCAN COMMAND
        if let characteristic = gattProfile.wifiIntroducerCommandControlCharacteristic{
            let command: [UInt8] = [1]
            let commandData = Data(bytes: command)
            super.write(value: commandData, toCharacteristic: characteristic)
        }
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func stopScanningForAccessPoints() {
        //SEND STOP SCAN COMMAND
        if let characteristic = gattProfile.wifiIntroducerCommandControlCharacteristic{
            let command: [UInt8] = [0]
            let commandData = Data(bytes: command)
            super.write(value: commandData, toCharacteristic: characteristic)
        }
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func connectToAccessPoint(ssid: String, passphrase: String) {
        
        print("Connect AP Called SSID \(ssid)  passphrase =\(passphrase)")
        if let ssidCharacterisitc = gattProfile.wifiIntroducerSsidCharacteristic{
            if let ssidData = ssid.data(using: .ascii) {
                super.write(value: ssidData, toCharacteristic: ssidCharacterisitc)
            }
        }
        
        if let passphraseCharacteristic = gattProfile.wifiIntroducerPassphraseCharacteristic{
            if let passphraseData = passphrase.data(using: .ascii){
                super.write(value: passphraseData, toCharacteristic: passphraseCharacteristic)
            }
        }
    }
    
    /**
     Description
     
     - Author:
     Joe Bakalor
     
     - returns:
     Nothing
     
     - throws:
     nothing
     
     - parmeters:
     
     Additional details
     
     */
    func disconnectFromAcessPoint() {
        
    }
    
}

extension WiFiIntroManager: PeripheralDiscoveryDelegate{
    
    func foundPeripheral(peripheral: CBPeripheral, advData: [String : Any], rssi: Int) {
        
        let localName = advData["kCBAdvDataLocalName"] as? String

        if (localName == "WiFiInt"){
            wifiIntroDevice = peripheral
            wifiIntroManager.stopScanning()
            wifiIntroDelegate?.foundWifiIntroducer()
            wifiIntroducerDelegate?.foundWifiIntroducer()
        }
    }

}

//MARK: BLERadioStatusDelegate, BLEConnectionDelegate
extension WiFiIntroManager: BLERadioStatusDelegate, BLEConnectionDelegate{
    
    func connected() {
        
        wifiIntroDelegate?.connectedToWifiIntroDevice()
        wifiIntroducerDelegate?.connectedToWifiIntroDevice()
        super.discoverServices(withUUIDS: nil)
    }
    
    func disconnected() {
        wifiIntroducerDelegate?.wifiIntroducerDeviceConnectionFailed()
    }
    
    func connectionFailed() {
        wifiIntroducerDelegate?.wifiIntroducerDeviceConnectionFailed()
    }
    
    func bluetoothReady() {
        bleReady = true
        wifiIntroDelegate?.radioReady()
        wifiIntroDelegate?.ready()
        wifiIntroducerDelegate?.ready()
    }
}

