//
//  GATTClientController.swift
//
//
//  Created by Joe Bakalor on 4/6/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreBluetooth


//MARK: DEBUG CONFIGURATION
struct DebugConfiguration{
    var debugPeripheral             = false
    var debugServices               = false
    var debugCharacteristics        = false
    var debugDescriptors            = false
}

//MARK: GATT Event Delegate Protocol Definition
protocol GATTEventDelegate: class{
    
    func gattClient(recievedNewValueFor characteristic: CBCharacteristic, value: Data?, error: Error?)
    func gattClient(wroteValueFor characteristic: CBCharacteristic, error: Error?)
    func gattClient(updatedNotificationStatusFor characteristic: CBCharacteristic, error: Error?)
    
    func gattClient(recievedNewValueForD descriptor: CBDescriptor, value: Any?, error: Error?)
    func gattClient(wroteValueForD descriptor: CBDescriptor, error: Error?)
    func gattClient(updatedRssiFor peripheral: CBPeripheral, rssi: Int, error: Error?)
}

//MARK: GATT DISCOVERY DELEGATE PROTOCOL DEFINITION
protocol GATTDiscoveryDelegate{
    func gattClient(foundServices services: [CBService]?, forPeripheral peripheral: CBPeripheral, error: Error?)
    func gattClient(foundCharacteristics characteristics: [CBCharacteristic]?, forService service: CBService, error: Error?)
    func gattClient(foundDescriptors discriptors: [CBDescriptor]?, forCharacteristic: CBCharacteristic, error: Error?)
}

//MARK:  BASE CLASS
class GATTClientController: NSObject, CBPeripheralDelegate
{
    
    //MARK: VARIABLE DECLARATIONS
    var debugConfiguration = DebugConfiguration()
    var delegate: GATTEventDelegate?
    
    var gattDiscoveryDelegate: GATTDiscoveryDelegate?
    fileprivate var gattServer: CBPeripheral?
    var gattServices: [CBService]?{
        get{
            return self.gattServer?.services
        }
    }
    
    //CLASS INITIALIZATION - ONLY SETUP TO MANAGE A SINGLE PERIPHERAL AT A TIME BUT
    //POSSIBLE TO CREATE ADDITIONAL INSTANCES OF THIS CLASS FOR EACH PERIPHERAL
    init(withPeripheral peripheral: CBPeripheral, gattEventDelegate: GATTEventDelegate?, gattDiscoveryDelegate: GATTDiscoveryDelegate?)
    {
        super.init()
        gattServer = peripheral
        delegate = gattEventDelegate
        self.gattDiscoveryDelegate = gattDiscoveryDelegate
        gattServer?.delegate = self
    }
    
    //CONFIGURE DEBUG OUTPUT
    func setDebugConfiguration(debugConfiguration: DebugConfiguration)
    {
        self.debugConfiguration = debugConfiguration
    }
}

//MARK:  PERIPHERAL STATE UPDATES
extension GATTClientController
{
    //RSSI VALUE WAS UPDATED FOR PERIPHERAL
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?)
    {
        if debugPeripheral {print("Did read RSSI for peripheral: \(RSSI)")}
        
        delegate?.gattClient(updatedRssiFor: peripheral, rssi: RSSI.intValue, error: error)
    }
    
    //PERIPHERAL UPDATED BT FRIENDLY NAME
    func peripheralDidUpdateName(_ peripheral: CBPeripheral)
    {
        if debugPeripheral {print("Peripheral updated name to \(peripheral.name ?? "NA")")}
    }
    
    //USE THIS TO SEND DATA RATHER THAN SENDING USING WRITE WITH RESPONSE
    //THIS WILL ALLOW RELIABILITY EVEN WHEN USING WRITE W/0 RESPONSE
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral)
    {
        if debugPeripheral {print("Peripheral ready to send write w/o response")}
    }
    
    //CALL THIS TO INITIATE A READ OF THE RSSI, DIDREADRSSI CALLED BY COREBT AFTER
    func getRssi()
    {
        if let peripheral = gattServer{
            peripheral.readRSSI()
        }
    }
}

//MARK: GATT ACTION METHODS
extension GATTClientController
{
    //DISCOVER SERVICES FOR GATT SERVER
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
    func startServiceDiscovery(services: [CBUUID]?)
    {
        if let gattSrvr = gattServer{
            
            //discover all services for GATT SERVER, aka peripheral
            gattSrvr.discoverServices(services)
            if debugConfiguration.debugServices {print("Start discovering services on peripheral")}
        }
    }
    
    //DISCOVER CHARCTERISTICS FOR SERVICES, SET CHARACTERISTICS TO NIL TO FIND ALL
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
    func startCharacteristicDiscovery(forService service: CBService, forCharacteristics characteristics: [CBUUID]?)
    {
        gattServer?.discoverCharacteristics(characteristics, for: service)
        
        if debugConfiguration.debugCharacteristics {}
    }
    
    //WRITE VALUE TO CHARACTERISTIC
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
    func writeCharacteristicValue(forCharacteristic characteristic: CBCharacteristic, value: Data, withResponse: Bool)
    {
        gattServer?.writeValue(value, for: characteristic, type: .withResponse)
        
        if debugConfiguration.debugCharacteristics {}
    }
    
    //READ CHARACTERISTIC VALUE
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
    func readCharacteristicValue(for characteristic: CBCharacteristic){
        gattServer?.readValue(for: characteristic)
    }
    
    //DISCOVER DISCRIPTORS FOR CHARACTERISTIC
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
    func startDiscriptorDiscovery(forCharacteristic characteristic: CBCharacteristic)
    {
        gattServer?.discoverDescriptors(for: characteristic)
    }
    
    //WRITE VALUE TO DESCRIPTOR
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
    func writeDescriptorValue(forDescriptor descriptor: CBDescriptor, value: Data)
    {
        gattServer?.writeValue(value, for: descriptor)
    }
    
}

//MARK:  SERVICE DELEGATE METHODS
extension GATTClientController
{
    
    //PERIPHERAL MODIFIED SERVICES ON GATTSERVER
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService])
    {
        
    }
    
    //DISCOVERED SERVICES FOR PERIPHERAL
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?)
    {
        let foundServices = peripheral.services
        
        //call delegate method
        gattDiscoveryDelegate?.gattClient(foundServices: foundServices, forPeripheral: peripheral, error: error)
        
        //debug
        if debugConfiguration.debugServices {print("Found services for peripheral: \(String(describing: foundServices))")}
    }
}

//MARK:  CHARACTERISTIC DELEGATE METHODS
extension GATTClientController
{
    //DISCOVERED CHARACTERISTICS FOR SERVICE
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    {
        let foundCharacteristics = service.characteristics
        
        //call delegate method
        gattDiscoveryDelegate?.gattClient(foundCharacteristics: foundCharacteristics, forService: service, error: error)
        
        //debug
        if debugConfiguration.debugCharacteristics {print("Found characteristics for service: \(String(describing: foundCharacteristics))")}
    }
    
    //VALUE WAS UPDATED FOR CHARACTERISTIC
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        let updatedValue = characteristic.value
        
        //call delegate methods
        delegate?.gattClient(recievedNewValueFor: characteristic, value: updatedValue, error: error)

        //debug
        if debugConfiguration.debugCharacteristics {print("Updated value for characteristic: \(String(describing: updatedValue))")}
    }
    
    //VALUE WAS WRITTEN TO CHARACTERISTIC
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?)
    {
        print("Value Written to Char with error \(error)")
        //call delegate method
        delegate?.gattClient(wroteValueFor: characteristic, error: error)
        
        //debug
        if debugConfiguration.debugCharacteristics {print("Wrote value for \(characteristic)")}
    }
    
    //NOTIFICATION STATE WAS UPDATED FOR CHARACTERISTIC
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?)
    {
        //call delegate method
        delegate?.gattClient(updatedNotificationStatusFor: characteristic, error: error)
        
        //debug
        if debugConfiguration.debugCharacteristics {print("Updated notification status for \(characteristic)")}
    }
    
}

//MARK:  DESCRIPTOR DELEGATE METHODS
extension GATTClientController
{
    //DISCOVERD DESCRIPTORS FOR CHARACTERISTIC
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?)
    {
        let foundDescriptors = characteristic.descriptors

        //call delegate method
        gattDiscoveryDelegate?.gattClient(foundDescriptors: foundDescriptors, forCharacteristic: characteristic, error: error)
        
        //debug
        if debugConfiguration.debugDescriptors {print("Found descriptors for service: \(String(describing: foundDescriptors))")}
    }

    //VALUE WAS UPDATED FOR DESCRIPTOR
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?)
    {
        let updatedValue = descriptor.value
        
        //call delegate methods
        delegate?.gattClient(recievedNewValueForD: descriptor, value: updatedValue, error: error)
        
        //debug
        if debugConfiguration.debugDescriptors {print("Updated value for descriptor: \(String(describing: updatedValue))")}
    }
    
    //VALUE WAS WRITTEN FOR DESCRIPTOR
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?)
    {
        //notification information library
        var notificationInformation: [String: AnyObject] = [:]
        
        //call delegate method
        delegate?.gattClient(wroteValueForD: descriptor, error: error)
        
        //debug
        if debugConfiguration.debugDescriptors {print("Wrote value for \(descriptor)")}
    }
}




















