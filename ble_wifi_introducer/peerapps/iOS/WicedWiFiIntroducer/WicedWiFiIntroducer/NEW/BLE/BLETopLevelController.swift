//
//  BLETopLevelController.swift
//  SelectComfort
//
//  Created by Joe Bakalor on 9/25/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth

//CREATE PROTOCOL DELEGATES FOR VIEW CONTROLLERS TO RECIEVE DATA
protocol BLERadioStatusDelegate{
    func bluetoothReady()
}

protocol PeripheralDiscoveryDelegate {
    func foundPeripheral(peripheral: CBPeripheral, advData: [String: Any], rssi: Int)
}

//TOP LEVEL CONNECTION DELEGATE PROTOCOL
protocol BLEConnectionDelegate{
    func connected()
    func disconnected()
    func connectionFailed()
}


protocol GattDelegate{
    func foundServices(services: [CBService])
    func foundCharacteristics(characteristics: [CBCharacteristic])
    func valueUpdatedFor(characteristic: CBCharacteristic)
}


//MARK: BASE CLASS
class BLETopLevelController: NSObject
{
    var centralController: BLECentralController!
    var connectedPeripheral: CBPeripheral?
    
    var bleStatusDelegate: BLERadioStatusDelegate!
    var connectionDelegate: BLEConnectionDelegate?
    var peripheralDiscoveryDelegate: PeripheralDiscoveryDelegate?
    var gattDelegate: GattDelegate?
    
    var radioReady: Bool{
        
        get{
            switch (centralController.getCBManagerState()){
            case .poweredOff: return false
            case .poweredOn: return true
            case .resetting: return false
            case .unauthorized: return false
            case .unknown: return false
            case .unsupported: return false
            }
        }
    }
    
    //CLASS INITIALIZATION
    init(bleStatusDelegate: BLERadioStatusDelegate?, _gattDelegate: GattDelegate?, _peripheralDiscoveryDelegate: PeripheralDiscoveryDelegate?)
    {
        super.init()
        self.bleStatusDelegate = bleStatusDelegate
        gattDelegate = _gattDelegate
        peripheralDiscoveryDelegate = _peripheralDiscoveryDelegate
        
        //INIT CENTRAL CONTROLLER WITHOUT GATT STRUCTURE, WE WILL DO THIS OURSELVES
        centralController = BLECentralController(delegate: self)
    }
    
    func setRadioStatusDelegate(delegate: BLERadioStatusDelegate){
        bleStatusDelegate = delegate
    }
    
    func setConnectionDelegate(delegate: BLEConnectionDelegate){
        connectionDelegate = delegate
    }
    
}

//=========================================================================
//MARK: GAP ACTION METHODS
extension BLETopLevelController
{
    //SCAN FOR PERIPHERALS, OPTIONALLY PROVIDE LIST OF SERVICE
    //UUIDS THAT PERIPHERALS SHOULD INCLUDE OTHERWISE USE NIL
    //TO RETURN ALL PERIPHERALS
    func startScanningForPeripherals(withServices services: [CBUUID]?)
    {
        print("Scan for service \(String(describing: services))")
        centralController.startScanningForPeripherals(withServiceUUIDS: nil)
    }
    
    //STOP SCANNING FOR PERIPHERALS
    func stopScanning()
    {
        centralController.stopScanning()
    }
    
    //CONNECT TO SPECIFIED PERIPHERAL USING TIMEOUT(SECONDS)
    //DISCONNECT FROM CONNECTED PERIPHERAL
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
    func connect(toPeripheral peripheral: CBPeripheral, withTimeout timeout: Int)
    {
        guard connectedPeripheral == nil else { return }
        centralController.attemptConnection(toPeriperal: peripheral, withTimeout: timeout)
    }
    
    //DISCONNECT FROM CONNECTED PERIPHERAL
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
    func disconnect()
    {
        guard let peripheral = connectedPeripheral else { return }
        centralController.disconnect(fromPeripheral: peripheral)
    }
}

//MARK: GAP EVENT DELEGATE METHODS
extension BLETopLevelController: GAPEventDelegate
{
    func centralController(foundPeripheral peripheral: CBPeripheral, with advertisementData: [String : Any], rssi RSSI: Int)
    {
        if false{
        print("ADVERTISEMENT DATA = \(advertisementData)")
        //Advertisment Data Keys
        let connectable           = advertisementData["kCBAdvDataIsConnectable"] as? NSNumber
        print("CONNECTABLE = \(String(describing: connectable))")
        
        let manufacturerData      = advertisementData["kCBAdvDataManufacturerData"] as? NSData
        print("MANUFACTURER DATA = \(String(describing: manufacturerData))")
        
        let overflowServiceUUIDs  = advertisementData["kCBAdvDataOverflowServiceUUIDs"] as? [CBUUID]
        print("OVERFLOW SERVICE UUIDS = \(String(describing: overflowServiceUUIDs))")
        
        let serviceData           = advertisementData["kCBAdvDataServiceData"] as? [CBUUID : NSData]
        print("SERVICE DATA = \(String(describing: serviceData))")
        
        let services              = advertisementData["kCBAdvDataServiceUUIDs"] as? [UUID]
        print("SERVICES = \(String(describing: services))")
        
        let solicitedServiceUUIDs = advertisementData["kCBAdvDataSolicitedServiceUUIDs"] as? [CBUUID]
        print("SOLICITED SERVICE UUIDS = \(String(describing: solicitedServiceUUIDs))")
        
        let txPowerLevel          = advertisementData["kCBAdvDataTxPowerLevel"] as? NSNumber
        print("TX POWER LEVEL = \(String(describing: txPowerLevel))")
        }
        let localName             = advertisementData["kCBAdvDataLocalName"] as? String
         //   print("LOCAL NAME = \(String(describing: localName))")
            
        if (localName == "STidget"){
            print("Found STidget, Call delegate")
            //stidget.foundSTidgetPeripheral(StidgetPeripheral: peripheral)
        }
        
        
        peripheralDiscoveryDelegate?.foundPeripheral(peripheral: peripheral, advData: advertisementData, rssi: RSSI)
        
    }
    
    func centralController(connectedTo peripheral: CBPeripheral)
    {
        connectedPeripheral = peripheral
        connectionDelegate?.connected()
    }
    
    func centralController(failedToConnectTo peripheral: CBPeripheral, with error: Error?)
    {
        connectedPeripheral = nil
    }
    
    func centralController(disconnectedFrom peripheral: CBPeripheral, with error: Error?)
    {
        print("Peripheral Disconnected")
        connectedPeripheral = nil
        connectionDelegate?.disconnected()
        
    }
    
    func centralController(updatedBluetoothStatusTo status: BluetoothState)
    {
        print("Updated Bluetooth Status to \(status)")
        switch status{
        case .off: print("radio off")
        case .on: print("radio on"); bleStatusDelegate.bluetoothReady()
        case .resetting: print("radio resetting")
        case .unauthorized: print("unauthorized")
        case .unsupported: print("unsupported")
        case .unknown: print("Unknown")
        }
    }
}

//=========================================================================
//MARK: GATT ACTION METHODS
extension BLETopLevelController
{
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
    func write(value: Data, toCharacteristic characteristic: CBCharacteristic)
    {
        guard connectedPeripheral != nil else { return }
        print("Write value to characteristic \(characteristic) value \(value)")
        connectedPeripheral?.writeValue(value, for: characteristic, type: .withResponse)
    }
    
    // TO DO
    //func writeBytes
    //func writeString
    
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
    func write(value: Data, toDescriptor descriptor: CBDescriptor)
    {
        guard connectedPeripheral != nil else { return }
        connectedPeripheral?.writeValue(value, for: descriptor)
       
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
    func read(valueFor characteristic: CBCharacteristic){
        
        //centralController.gattClient?.readCharacteristicValue(for: characteristic)
        guard connectedPeripheral != nil else { return }
        connectedPeripheral?.readValue(for: characteristic)
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
    func enableNotifications(forCharacteristic characteristic: CBCharacteristic)
    {
        print("BLETopLevelController: ENABLE NOTIFICATIONS")
        guard connectedPeripheral != nil else { return }
        connectedPeripheral?.setNotifyValue(true, for: characteristic)
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
    func disableNotifications(forCharacteristic characteristic: CBCharacteristic)
    {
        guard connectedPeripheral != nil else { return }
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
    func updateRSSI(forPeripheral: CBPeripheral)
    {
        guard connectedPeripheral != nil else { return }
    }
    
    
}

//MARK: GATT EVENT DELEGATE METHODS
extension BLETopLevelController: GATTEventDelegate
{
    func gattClient(recievedNewValueFor characteristic: CBCharacteristic, value: Data?, error: Error?)
    {
        //stidgetGATT.valueUpdatedFor(characteristic: characteristic)
        gattDelegate?.valueUpdatedFor(characteristic: characteristic)
        
    }
    
    func gattClient(wroteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        
    }
    
    func gattClient(updatedNotificationStatusFor characteristic: CBCharacteristic, error: Error?)
    {
        
    }
    
    func gattClient(recievedNewValueForD descriptor: CBDescriptor, value: Any?, error: Error?)
    {
        
    }
    
    func gattClient(wroteValueForD descriptor: CBDescriptor, error: Error?)
    {
        
    }
    
    func gattClient(updatedRssiFor peripheral: CBPeripheral, rssi: Int, error: Error?)
    {
        
    }
}

//=========================================================================
//MARK: GATT DISCOVERY ACTION METHODS
extension BLETopLevelController
{
    //DISCOVER SERVICES FOR CONNECTED PERIPHERAL. OPTIONALLY PROVIDE LIST OF SERVICE
    //UUIDS TO DISCOVER. TO DISCOVER ALL, SPECIFY NIL
    func discoverServices(withUUIDS uuids: [CBUUID]?)
    {
        guard connectedPeripheral != nil else { return }
        centralController.gattClient?.startServiceDiscovery(services: uuids)
        
    }
    
    //DISCOVER CHARACTERISTICS FOR SERVICE. OPTIONALLY PROVIDE LIST OF CHARACTERISTICS
    //UUIDS TO DISCOVER. TO DISCOVER ALL, SPECIFY NIL
    func discoverCharacteristics(forService service: CBService, withUUIDS uuids: [CBUUID]?)
    {
        guard connectedPeripheral != nil else { return }
        centralController.gattClient?.startCharacteristicDiscovery(forService: service, forCharacteristics: uuids)
    }
}

//MARK: GATT DISCOVERY DELEGATE METHODS
extension BLETopLevelController: GATTDiscoveryDelegate
{
    func gattClient(foundServices services: [CBService]?, forPeripheral peripheral: CBPeripheral, error: Error?)
    {
        
        if let discoveredServices = services{
            gattDelegate?.foundServices(services: discoveredServices)
        }
        
    }
    
    func gattClient(foundCharacteristics characteristics: [CBCharacteristic]?, forService service: CBService, error: Error?)
    {
        if let discoveredCharacteristics = characteristics{
            gattDelegate?.foundCharacteristics(characteristics: discoveredCharacteristics)
        }
    }
    
    func gattClient(foundDescriptors discriptors: [CBDescriptor]?, forCharacteristic: CBCharacteristic, error: Error?)
    {
        
    }
    
}
