//
//  BLECentralController.swift
//  BLU
//
//  Created by Joe Bakalor on 4/6/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth

//BLUETOOTH NOTIFICATION DEFINES

//GAP EVENT NOTIFICATIONS
let FOUND_PERIPHERAL                        = Notification.Name(rawValue: "foundPeripheral")
let CONNECTED_TO_PERIPHERAL                 = Notification.Name(rawValue: "connectedToPeripheral")
let FAILED_TO_CONNECT_TO_PERIPHERAL         = Notification.Name(rawValue: "failedToConnectToPeripheral")
let DISCONNECTED_FROM_PERIPHERAL            = Notification.Name(rawValue: "disconnectedFromPeripheral")
let BLUETOOTH_POWERED_ON                    = Notification.Name(rawValue: "bluetoothPoweredOn")

enum BluetoothState{
    case off
    case on
    case unauthorized
    case unknown
    case resetting
    case unsupported
}

//MARK:  GAP EVENT DELEGATE PROTOCOL DEFINITION
protocol GAPEventDelegate{
    func centralController(foundPeripheral peripheral: CBPeripheral, with advertisementData: [String: Any], rssi RSSI: Int)
    func centralController(connectedTo peripheral: CBPeripheral)
    func centralController(failedToConnectTo peripheral: CBPeripheral, with error: Error?)
    func centralController(disconnectedFrom peripheral: CBPeripheral, with error: Error?)
    func centralController(updatedBluetoothStatusTo status: BluetoothState)
}

var debugPeripheral = true

//MARK: BASE CLASS
class BLECentralController: NSObject
{
    //VARIABLE DECLARATIONS
    fileprivate var centralManager        : CBCentralManager?
    var peripheralPendingConnection       : CBPeripheral?
    var connectedPeripheral               : CBPeripheral?
    var gattClient                        : GATTClientController?
    var connectionTimeoutTimer            : Timer?
    var delegate                          : GAPEventDelegate?
    
    //CLASS INITIALIZATION
    init(delegate: Any)
    {
        self.delegate = delegate as? GAPEventDelegate
        print("Initialize BLE Central Controller")
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
}

//MARK: CENTRAL CONTROLER ACTION METHODS
extension BLECentralController
{
    //CHECK CENTRAL MANAGER STATE
    func getCBManagerState() -> CBManagerState
    {
        let cbState = centralManager?.state
        return cbState!
    }

    //BEGIN SCANNING FOR PERIPHERALS
    func startScanningForPeripherals(withServiceUUIDS UUIDS: [CBUUID]?)
    {
            //Verify centralManager is valid
            if let central = centralManager{
                print("BLECentralController: StartScanning")
                //Begin scanning for peripherals with specified service UUIDS
                central.scanForPeripherals(withServices: UUIDS, options: nil)
                central.scanForPeripherals(withServices: nil, options: nil)
            }
    }
    
    //STOP SCANNING FOR PERIPHERALS
    func stopScanning()
    {
        if let central = centralManager{
            central.stopScan()
        }
    }
    
    //ATTEMPT CONNECTION TO SPECIFIED PERIPHERAL
    func attemptConnection(toPeriperal peripheral: CBPeripheral, withTimeout: Int)
    {
        peripheralPendingConnection = peripheral
        //Verify centralManager exists
        if let central = centralManager{
            //Attempt to form connection with specified peripheral
            central.connect(peripheral, options: nil)
        }
    }
    
    //CANCEL ACTIVE OR PENDING PERIPHERAL CONNECTION
    func disconnect(fromPeripheral peripheral: CBPeripheral)
    {
        if let central = centralManager{
            //cancel connection and/or connection attempt to peripheral
            central.cancelPeripheralConnection(peripheral)
        }
    }
    
    //RETURN LIST OF CONNECTED PERIPHERALS, OPTIONALLY SPECIFIY SERVICES
    func getConnectedPeripherals(withServices services: [CBUUID])
    {
        
    }
}

//MARK: CENTRAL MANAGER DELEGATE METHODS
extension BLECentralController: CBCentralManagerDelegate
{
    //CALLED FOR SUCCESSFUL CONNECTION TO PERIPHERAL
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        //initialize class instance of GATTClientController with connected
        //peripheral and set the peripherals delegate to that instance
        //set centralcontroller delegate as gatt delegate
        gattClient = GATTClientController(withPeripheral: peripheral, gattEventDelegate: self.delegate! as? GATTEventDelegate, gattDiscoveryDelegate: self.delegate! as? GATTDiscoveryDelegate)
        peripheral.delegate = gattClient
        
        //set state variables
        connectedPeripheral = peripheral
        peripheralPendingConnection = nil
        
        //call delegate method
        delegate?.centralController(connectedTo: peripheral)
        print("CONNECTED")
    }
    
    //CALLED WHEN PERIPHERAL DISCONNECTION OCCURS
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?)
    {
        print("Disconnected with ERROR: \(String(describing: error))")
        //set state variables
        connectedPeripheral = nil
        peripheralPendingConnection = nil
        
        //call delegate method
        delegate?.centralController(disconnectedFrom: peripheral, with: error)
    }
    
    //CALLED FOR EACH PERIPHERAL DISCOVERED
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    {
        //Advertisment Data Keys
        /*
         //  CBAdvertisementDataIsConnectable
         //  CBAdvertisementDataLocalNameKey
         //  CBAdvertisementDataManufacturerDataKey
         //  CBAdvertisementDataOverflowServiceUUIDsKey
         //  CBAdvertisementDataServiceDataKey
         //  CBAdvertisementDataSolicitedServiceUUIDsKey
         //  CBAdvertisementDataTxPowerLevelKey
         */
        //print("Found Peripheral")
        delegate?.centralController(foundPeripheral: peripheral, with: advertisementData, rssi: RSSI.intValue)
    }
    
    //  CALLED WHEN CONNECTION ATTEMPT TO PERIPHERAL FAILS
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?)
    {
        peripheralPendingConnection = nil
        
        delegate?.centralController(failedToConnectTo: peripheral, with: error)
        
        if debugPeripheral{ print("Connection to peripheral failed with error = \(String(describing: error))") }
    }
    
    //BLUETOOTH STATUS UPDATES
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    {

        if #available(iOS 10.0, *)
        {
            switch (central.state)
            {
            case CBManagerState.poweredOff:
                print("CBManager Powered Off")
                delegate?.centralController(updatedBluetoothStatusTo: .off)
                break
            case CBManagerState.unauthorized:
                delegate?.centralController(updatedBluetoothStatusTo: .unauthorized)
                break
            case CBManagerState.unknown:
                delegate?.centralController(updatedBluetoothStatusTo: .unknown)
                break
            case CBManagerState.poweredOn:
                delegate?.centralController(updatedBluetoothStatusTo: .on)
                print("does this get called")
                break
            case CBManagerState.resetting:
                delegate?.centralController(updatedBluetoothStatusTo: .resetting)
                break
            case CBManagerState.unsupported:
                delegate?.centralController(updatedBluetoothStatusTo: .unsupported)
                break
            }
        }else{
            
        }
    }
}





















