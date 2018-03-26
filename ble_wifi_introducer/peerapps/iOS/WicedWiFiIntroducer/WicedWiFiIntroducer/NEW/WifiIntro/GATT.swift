//
//  GATT.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/9/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import Foundation
import CoreBluetooth

enum WiFiIntroChars{
    case security
    case ssid
    case passphrase
    case scanResult
    case notify
    case commandControl
}

enum CharacteristicID{
    case unknown
    case security
    case ssid
    case passphrase
    case scanResult
    case notify
    case commandControl
}

protocol CharValueUpdateDelegate{
    func newValue(forCharacteristic characteristic: WiFiIntroChars, value: Any)
}

protocol GattDeltaDelegate{
    func characteristicValueChanged(forCharacteristic characteristic: CharacteristicID, to value: Any)
}

//DEFINE SERVICE AND CHARACTERISTIC UUIDS
let WIFI_INTRODUCER_SERVICE_UUID                        = CBUUID(string: "1B7E8251-2877-41C3-B46E-CF057C562023")
let WIFI_INTRODUCER_CHARACTERISTIC_SECURITY_UUID        = CBUUID(string: "CAC2ABA4-EDBB-4C4A-BBAF-0A84A5CD93A1")//
let WIFI_INTRODUCER_CHARACTERISTIC_SSID_UUID            = CBUUID(string: "ACA0EF7C-EEAA-48AD-9508-19A6CEF6B356")//
let WIFI_INTRODUCER_CHARACTERISTIC_PASPHRASE_UUID       = CBUUID(string: "40B7DE33-93E4-4C8B-A876-D833B415A6CE")//
let WIFI_INTRODUCER_CHARACTERISTIC_SCAN_RESULT_UUID     = CBUUID(string: "41B7DE33-93E4-4C8B-A876-D833B415A6CE")//
let WIFI_INTRODUCER_CHARACTERISTIC_NOTIFY_UUID          = CBUUID(string: "8AC32D3f-5CB9-4D44-BEC2-EE689169F626")//
let WIFI_INTRODUCER_CHARACTERISTIC_COMMAND_CONTROL_UUID = CBUUID(string: "42B7DE33-93E4-4C8B-A876-D833B415A6CE")//

class GATT: NSObject, GattDelegate{
    
    var charUpdateDelegate: CharValueUpdateDelegate?
    var gattDeltaDelegate: GattDeltaDelegate?
    
    func setCharUpdateDelegate(delegate: CharValueUpdateDelegate){
        charUpdateDelegate = delegate
    }
    
    func setGattDeltaDelegate(_gattDeltaDelegate: GattDeltaDelegate){
        self.gattDeltaDelegate = _gattDeltaDelegate
    }
    
    struct characteristic{
        var characteristic: CBCharacteristic?
        var uuid: CBUUID
        var enableNotifications: Bool = false
    }
    
    struct service{
        var service: CBService?
        var uuid: CBUUID
    }
    
    struct Service {
        var service: service?
        var characteristics: [characteristic]?
    }
    
    struct GATTProfile {
        var services: [Service]
    }
    
    private var _gattProfile: GATTProfile?
    private var _gattProfileCopy: GATTProfile?
    
    func altInit(gattProfile: inout GATTProfile){
        _gattProfile = gattProfile
        _gattProfileCopy = gattProfile
    }
    
    

    //DEFINE PUBLIC ACCESS VARIABLE
    public var wiFiIntroducerService: CBService?{
        get{
            return self.WiFiIntroducerService?.service
        }
    }
    
    //DEFINE PUBLIC ACCESS VARIABLE
    public var wifiIntroducerSecurityCharacteristic: CBCharacteristic?{
        get{
            return self.WifiIntroducerSecurityCharacteristic?.characteristic
        }
    }
    
    //DEFINE PUBLIC ACCESS VARIABLE
    public var wifiIntroducerSsidCharacteristic: CBCharacteristic?{
        get{
            return self.WifiIntroducerSsidCharacteristic?.characteristic
        }
    }
    
    //DEFINE PUBLIC ACCESS VARIABLE
    public var wifiIntroducerPassphraseCharacteristic: CBCharacteristic?{
        get{
            return self.WifiIntroducerPassphraseCharacteristic?.characteristic
        }
    }
    
    //DEFINE PUBLIC ACCESS VARIABLE
    public var wifiIntroducerScanResultCharacteristic: CBCharacteristic?{
        get{
            return self.WifiIntroducerScanResultCharacteristic?.characteristic
        }
    }
    
    //DEFINE PUBLIC ACCESS VARIABLE
    public var wifiIntroducerNotifyCharacteristic: CBCharacteristic?{
        get{
            return self.WifiIntroducerNotifyCharacteristic?.characteristic
        }
    }
    
    //DEFINE PUBLIC ACCESS VARIABLE
    public var wifiIntroducerCommandControlCharacteristic: CBCharacteristic?{
        get{
            return self.WifiIntroducerCommandControlCharacteristic?.characteristic
        }
    }
    
    //CREAT PRIVATE VARIABLES TO STORE STIDGET SERVICE AND CHARACTERISTIC REFERENCES
    private var WiFiIntroducerService                       : service?        = service(service: nil, uuid: WIFI_INTRODUCER_SERVICE_UUID)//: CBService?
    
    private var WifiIntroducerSecurityCharacteristic        : characteristic? = characteristic(characteristic: nil,
                                                                                               uuid: WIFI_INTRODUCER_CHARACTERISTIC_SECURITY_UUID,
                                                                                               enableNotifications: false)
    
    private var WifiIntroducerSsidCharacteristic            : characteristic? = characteristic(characteristic: nil,
                                                                                               uuid: WIFI_INTRODUCER_CHARACTERISTIC_SSID_UUID,
                                                                                               enableNotifications: false)
    
    private var WifiIntroducerPassphraseCharacteristic      : characteristic? = characteristic(characteristic: nil,
                                                                                               uuid: WIFI_INTRODUCER_CHARACTERISTIC_PASPHRASE_UUID,
                                                                                               enableNotifications: false)
    
    private var WifiIntroducerScanResultCharacteristic      : characteristic? = characteristic(characteristic: nil,
                                                                                               uuid: WIFI_INTRODUCER_CHARACTERISTIC_SCAN_RESULT_UUID,
                                                                                               enableNotifications: true)
    
    private var WifiIntroducerNotifyCharacteristic          : characteristic? = characteristic(characteristic: nil,
                                                                                               uuid: WIFI_INTRODUCER_CHARACTERISTIC_NOTIFY_UUID,
                                                                                               enableNotifications: true)
    
    private var WifiIntroducerCommandControlCharacteristic  : characteristic? = characteristic(characteristic: nil,
                                                                                               uuid: WIFI_INTRODUCER_CHARACTERISTIC_COMMAND_CONTROL_UUID,
                                                                                               enableNotifications: false)
    
    //LOOK THROUGH DISCOVERED SERVICES FOR SERVICES WE ARE INTERESTED IN
    func foundServices(services: [CBService]){
        print("GATT: Found Service called by super")
        
        for Service in services{
            switch Service.uuid{
            case WIFI_INTRODUCER_SERVICE_UUID:
                
                print("GATT: FOUND WIFI_INTRODUCER_SERVICE_UUID")
                WiFiIntroducerService?.service = Service
                guard let service = wiFiIntroducerService else {return}
                wifiIntroManager.discoverCharacteristics(forService: service, withUUIDS: nil)
                
            default:
                print("Unknown Service")
            }
        }
        
    }

    //LOOK THROUGH DISCOVERED CHARACTERISTICS FOR CHARACTERISTICS WE ARE INTERESTED IN
    func foundCharacteristics(characteristics: [CBCharacteristic]){
        
        for Characteristic in characteristics{
            
            switch Characteristic.uuid{
            case WIFI_INTRODUCER_CHARACTERISTIC_SECURITY_UUID:
                
                print("GATT: Found WIFI_INTRODUCER_CHARACTERISTIC_SECURITY_UUID")
                configureCharacteristic(_characteristic: &WifiIntroducerSecurityCharacteristic, cbCharacteristic: Characteristic)

            case WIFI_INTRODUCER_CHARACTERISTIC_SSID_UUID:
                
                print("GATT: Found WIFI_INTRODUCER_CHARACTERISTIC_SSID_UUID")
                configureCharacteristic(_characteristic: &WifiIntroducerSsidCharacteristic, cbCharacteristic: Characteristic)
                
            case WIFI_INTRODUCER_CHARACTERISTIC_PASPHRASE_UUID:
                
                print("GATT: Found WIFI_INTRODUCER_CHARACTERISTIC_PASPHRASE_UUID")
                configureCharacteristic(_characteristic: &WifiIntroducerPassphraseCharacteristic, cbCharacteristic: Characteristic)
                
            case WIFI_INTRODUCER_CHARACTERISTIC_SCAN_RESULT_UUID:
                
                print("GATT: Found WIFI_INTRODUCER_CHARACTERISTIC_SCAN_RESULT_UUID")
                configureCharacteristic(_characteristic: &WifiIntroducerScanResultCharacteristic, cbCharacteristic: Characteristic)
   
            case WIFI_INTRODUCER_CHARACTERISTIC_NOTIFY_UUID:
                
                print("GATT: Found WIFI_INTRODUCER_CHARACTERISTIC_NOTIFY_UUID")
                configureCharacteristic(_characteristic: &WifiIntroducerNotifyCharacteristic, cbCharacteristic: Characteristic)

            case WIFI_INTRODUCER_CHARACTERISTIC_COMMAND_CONTROL_UUID:
                
                print("GATT: Found WIFI_INTRODUCER_CHARACTERISTIC_COMMAND_CONTROL_UUID")
                configureCharacteristic(_characteristic: &WifiIntroducerCommandControlCharacteristic, cbCharacteristic: Characteristic)
                
            default:
                print("Unknown Characteristic")
            }
        }
    }
    //CHARACTERISTIC SETUP HELPER METHOD
    func configureCharacteristic( _characteristic: inout characteristic?, cbCharacteristic: CBCharacteristic){
        
        _characteristic?.characteristic = cbCharacteristic
        guard _characteristic?.enableNotifications == true else { return }
        wifiIntroManager.enableNotifications(forCharacteristic: cbCharacteristic)
    }
    
    //PROCESS CHARACTERISTIC UPDATES
    func valueUpdatedFor(characteristic: CBCharacteristic){
        
        ///print("STidgetGATT: VALUE UPDATED FOR CHARACTERISTIC")
        var characteristicUpdated: WiFiIntroChars = .notify
        var characteristicID: CharacteristicID = .unknown
        
        switch characteristic.uuid{
        case WIFI_INTRODUCER_CHARACTERISTIC_SECURITY_UUID:
            
            characteristicUpdated = .security
            characteristicID = .security
            
        case WIFI_INTRODUCER_CHARACTERISTIC_SSID_UUID:
            
            characteristicUpdated = .ssid
            characteristicID = .ssid
            
        case WIFI_INTRODUCER_CHARACTERISTIC_PASPHRASE_UUID:
            
            characteristicUpdated = .passphrase
            characteristicID = .passphrase
            
        case WIFI_INTRODUCER_CHARACTERISTIC_SCAN_RESULT_UUID:
            
            characteristicUpdated = .scanResult
            characteristicID = .scanResult
            
            let ssid = getStringFromDataBytes(characteristic: characteristic)
            if let validString = ssid{
                //print("\n\r SSID = \(validString)")
                charUpdateDelegate?.newValue(forCharacteristic: characteristicUpdated, value: validString)
                gattDeltaDelegate?.characteristicValueChanged(forCharacteristic: characteristicID, to: validString)
            }
            
            return
            
        case WIFI_INTRODUCER_CHARACTERISTIC_NOTIFY_UUID:
            
            print("GATT: NOTIFICATION FROM NOTIFY CHARCTERISTIC")
            characteristicUpdated = .notify
            characteristicID = .notify
            
            charUpdateDelegate?.newValue(forCharacteristic:.notify, value: "")
            gattDeltaDelegate?.characteristicValueChanged(forCharacteristic: characteristicID, to: "")
            
            return
            
        case WIFI_INTRODUCER_CHARACTERISTIC_COMMAND_CONTROL_UUID:
            
            characteristicUpdated = .commandControl
            
        default:
            print("Unknown Characteristic Data Updated")
        }
        

        charUpdateDelegate?.newValue(forCharacteristic: characteristicUpdated, value: getDataBytes(characteristic: characteristic))
    }
    
}

//MARK: DATA PARSING FUNCTIONS
extension GATT{
    
    //GET CHARACTERISTIC VALUE AND RETURN AS BYTE ARRAY
    func getDataBytes(characteristic: CBCharacteristic) -> [UInt8]{
        
        var data: Data? = characteristic.value as Data!
        //data = characteristic.value as Data!
        
        var dataBytes = [UInt8](repeating: 0, count: data!.count)
        (data! as NSData).getBytes(&dataBytes, length: data!.count)
        
        var hexValue = ""
        for value in data!{
            let hex = String(value, radix: 16)
            hexValue = hexValue + "0x\(hex) "
        }
        //print("Raw Hex = \(hexValue)")
        return dataBytes
    }
    
    //GET CHARACTERISTIC VALUE AND RETURN AS STRING
    func getStringFromDataBytes(characteristic: CBCharacteristic) -> String?{
        
        let data: Data? = characteristic.value as Data!
        let string = String(data: data!, encoding: .utf8)
        //print("SSID \(string)")
        if let ssidString = string{
            return ssidString
        } else {
            return nil
        }
        
    }
}





/*WifiIntroducerSecurityCharacteristic?.characteristic = Characteristic
 
 guard WifiIntroducerSecurityCharacteristic?.enableNotifications == true else {break}
 guard let characteristic = wifiIntroducerSecurityCharacteristic else {break}
 
 wifiIntroManager.enableNotifications(forCharacteristic: characteristic)*/










