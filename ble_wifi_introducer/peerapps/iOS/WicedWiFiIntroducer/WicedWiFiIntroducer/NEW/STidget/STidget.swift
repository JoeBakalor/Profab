////
////  STidget.swift
////  STidget
////
////  Created by Joe Bakalor on 11/30/17.
////  Copyright © 2017 Joe Bakalor. All rights reserved.
////
//
//import Foundation
//import UIKit
//import CoreBluetooth
//
//class STidget: BLETopLevelController{
//
//    //STIDGET LOCAL PARAMETER STRUCT
//    private struct StidgetParameterValues{
//        var acceleration                : (x: Int16, y: Int16, z: Int16) = (0,0,0)
//        var gyroscope                   : (x: Int16, y: Int16, z: Int16) = (0,0,0)
//        var prox                        : Int16                               = 0
//        var ambientLightLevel           : UInt16                               = 0
//        var temperature                 : Int16                            = 0
//        var rpm                         : UInt16                               = 0
//    }
//
//    //PRIVATE VARIABLES
//    private var stidgetParamtervalues   = StidgetParameterValues()
//    private var stidgetPeripheral       : CBPeripheral?
//    private var stidgetStatus           : STidgetStatus = .idle
//    private var bleReady                : Bool = false
//    private var startScanningFlag       = false
//
//    //STIDGET SERVICES DELEGATES
//    private var motionDelegate: motionServiceDelegate?
//    private var environmentDelegate: environmentalServiceDelegate?
//    private var ledDelegate: ledServiceDelegate?
//    private var stidgetDeviceManager: STidgetDeviceManager?
//    private var disconnectionDelegate: STidgetConnectionFailureDelegate?
//
//    //INITIALIZE CLASS
//    init() {
//        //INTIALIZE SUPER CLASS
//        super.init(bleStatusDelegate: self)
//    }
//}
//
////MARK: STIDGET API IMPLIMENTATION
//extension STidget: STidgetAPI{
//
//
//
//
//    /**
//
//     Get current stidget status
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     STidgetStatus Enum
//
//     - throws:
//     none
//
//     - parmeters:
//     none
//
//     */
//    func getSTidgetStatus() -> STidgetStatus{
//        return stidgetStatus
//    }
//
//    /**
//
//     Get current stidget status
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     STidgetStatus Enum
//
//     - throws:
//     none
//
//     - parmeters:
//     none
//
//     */
//    func setDisconnectionDelegate(delegate: STidgetConnectionFailureDelegate?){
//
//        guard let Delegate = delegate else {
//            self.disconnectionDelegate = nil
//            return
//        }
//        disconnectionDelegate = Delegate
//    }
//
//    /**
//     Set delegate to recieve stidget discovery and connection related updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func setDeviceManager(Manager: STidgetDeviceManager?){
//
//        guard let manager = Manager else {
//            self.stidgetDeviceManager = nil
//            return
//        }
//        print("Set device manager")
//        self.stidgetDeviceManager = manager
//
//    }
//
//    /**
//     Set delegate to recieve motion updates and stidget connection changes
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func setMotionDelegate(Delegate: motionServiceDelegate?){
//
//        guard let delegate = Delegate else {
//            self.motionDelegate = nil
//            return
//        }
//        self.motionDelegate = delegate
//    }
//
//
//    /**
//     Set delegate to recieve environmental updates and connection changes
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func setEnvironmentalDelegate(Delegate: environmentalServiceDelegate?){
//
//        guard let delegate = Delegate else {
//            self.environmentDelegate = nil
//            return
//        }
//        self.environmentDelegate = delegate
//    }
//
//
//    /**
//     Set delegate to recieve led updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func setLedDelegate(Delegate: ledServiceDelegate?){
//
//        guard let delegate = Delegate else {
//            self.ledDelegate = nil
//            return
//        }
//        self.ledDelegate = delegate
//    }
//
//    /**
//     Discover the STidget
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     Initiates scanning for STidget using STidget UUIDS
//
//    */
//    func discover() {
//
//        if bleReady{
//            print("Start Scanning for STidgets")
//            super.startScanningForPeripherals(withServices: nil)
//            //super.startScanningForPeripherals(withServices: [STIDGET_TEST_UUID])//[STIDGET_PRIMARY_SERVICE_UUID])
//            stidgetStatus = .searching
//        } else {
//            startScanningFlag = true
//            stidgetStatus = .idle
//        }
//
//    }
//
//    /**
//     Connect to the STidget
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     Attempt to connect to the STidget if it has already been found and the BLE radio
//     is ready.  When the timeout expires, the connection attempt will be abandonded
//     and the connectionFailed() method will be called on the stidgetDelegate.
//
//     */
//    func connect() {
//        //RETURN IF BLE IS NOT READY
//        guard bleReady else { return }
//
//        //CONNECT TO STIDGET, TIMEOUT OUT AFTER 5 IF CONNECTION NO COMPLETE
//        if let peripheral = stidgetPeripheral{
//            super.connect(toPeripheral: peripheral, withTimeout: 5)
//        }
//    }
//
//    /**
//     Set delegate to recieve motion updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func disconnect() {
//        super.diconnect()
//    }
//
//    /**
//     Set delegate to recieve motion updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func rpm() -> (UInt16) {
//
//        if let characteristic = stidgetGATT.stidgetAccelRpmGyroCharacteristic{
//            super.read(valueFor: characteristic)
//        }
//
//        return stidgetParamtervalues.rpm
//    }
//
//    /**
//     Set delegate to recieve motion updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func temperature() -> (Int16) {
//
//        if let characteristic = stidgetGATT.stidgetTemperatureCharacteristic{
//            super.read(valueFor: characteristic)
//        }
//
//        return stidgetParamtervalues.temperature
//    }
//
//    /**
//     Set delegate to recieve motion updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func acceleration() -> (x: Int16, y: Int16, z: Int16) {
//
//        if let characteristic = stidgetGATT.stidgetAccelRpmGyroCharacteristic{
//            super.read(valueFor: characteristic)
//        }
//
//        return stidgetParamtervalues.acceleration as! (x: Int16, y: Int16, z: Int16)
//    }
//
//    /**
//     Set delegate to recieve motion updates
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func gyroscope() -> (x: Int16, y: Int16, z: Int16) {
//
//        if let characteristic = stidgetGATT.stidgetAccelRpmGyroCharacteristic{
//            super.read(valueFor: characteristic)
//        }
//
//        return stidgetParamtervalues.gyroscope as! (x: Int16, y: Int16, z: Int16)
//    }
//
//    /**
//     Reads local value for proximity and submits read request to update value
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func proximity() -> (Int16) {
//
//        if let characteristic = stidgetGATT.stidgetAmbLightProxCharacteristic{
//            super.read(valueFor: characteristic)
//        }
//
//        return stidgetParamtervalues.prox
//    }
//
//    /**
//     Reads current local value for Ambient light and submits read request to update value
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     Nothing
//
//     - throws:
//     nothing
//
//     - parmeters:
//
//     */
//    func ambientLightLevel() -> (UInt16) {
//
//        if let characteristic = stidgetGATT.stidgetAmbLightProxCharacteristic{
//            super.read(valueFor: characteristic)
//        }
//
//        return stidgetParamtervalues.ambientLightLevel
//    }
//
//
//    /**
//     Set STidget LED Color
//
//     - Author:
//     Joe Bakalor
//
//     - returns:
//     True if command successful, false otherwise
//
//     - throws:
//     nothing
//
//     - parmeters:
//     New color of type UIColor to set the LED
//
//     */
//    func setLedColor(red: UInt8, green: UInt8, blue: UInt8){
//        //RGB LED: [Red uint8] [Green uint8] [Blue uint8]
//        print("Red: \(red) Green: \(green) Blue: \(blue)")
//        let byteArray = [red, green, blue]
//        let data = Data(buffer: UnsafeBufferPointer(start: byteArray, count: byteArray.count))
//
//        if let characteristic = stidgetGATT.stidgetRgbLedCharacteristic{
//           super.write(value: data, toCharacteristic: characteristic)
//        }
//    }
//}
//
//// MARK:
//extension STidget: BLERadioStatusDelegate{
//    func bluetoothReady() {
//        bleReady = true
//        if startScanningFlag && stidgetStatus == .idle{
//            print("Start Scanning for STidgets")
//            stidgetStatus = .searching
//            super.startScanningForPeripherals(withServices: nil)
//        }
//    }
//}
//
////  MARK: HANDLE MESSAGES FROM LOWER LEVEL BLE LIBRARIES
//extension STidget: STidgetAPIDelegate{
//
//    func disconnected() {
//        stidgetStatus = .idle
//        stidgetDeviceManager?.disconnected!()
//        disconnectionDelegate?.stidgetConnectionFailed()
//    }
//
//    func connectionFailed() {
//        stidgetStatus = .idle
//        stidgetDeviceManager?.connectionFailed!()
//    }
//
//    func connected() {
//        print("Is this connected called?")
//        stidgetStatus = .connected
//
//        if let deviceManager = stidgetDeviceManager{
//            deviceManager.connected!()
//        }
//        print("Start Service Discovery")
//        super.discoverServices(withUUIDS: nil)
//        //stidgetDeviceManager?.connected()
//    }
//
//    func foundSTidgetPeripheral(StidgetPeripheral: CBPeripheral) {
//        stidgetPeripheral = StidgetPeripheral
//        stidgetStatus = .found
//        stidgetDeviceManager?.foundStidget()
//        super.stopScanning()
//        stidgetStatus = .connecting
//        print("ATTEMPTING TO CONNECT TO STIDGET")
//    }
//
//    func updatedParameter(for parameter: STidgetParameters, newValue: Any) {
//
//        switch parameter {
//        //======================
//        case .ACCEL:
//            let accelerometerUpdate = newValue as! (x: Int16, y: Int16, z: Int16)
//            motionDelegate?.accelerometerUpdated(to: accelerometerUpdate.x, y: accelerometerUpdate.y, z: accelerometerUpdate.z)
//            stidgetParamtervalues.acceleration = accelerometerUpdate //as! (x: Int16, y: Int16, Z: Int16)
//
//        //======================
//        case .GYRO:
//            let gyroscopeUpdate = newValue as! (x: Int16, y: Int16, z: Int16)
//            motionDelegate?.gyroUpdated(to: gyroscopeUpdate.x, y: gyroscopeUpdate.y, z: gyroscopeUpdate.z)
//            stidgetParamtervalues.gyroscope = gyroscopeUpdate //as! (x: Int16, y: Int16, Z: Int16)
//
//        //======================
//        case .LED: print("No value to recieve currently")
//
//        //======================
//        case .LIGHT:
//            let ambientLightLevelUpdate = newValue as! UInt16
//            environmentDelegate?.lightLevelUpdated(to: ambientLightLevelUpdate)
//            stidgetParamtervalues.ambientLightLevel = ambientLightLevelUpdate//newValue as! (x: Double, y: Double, Z: Double)
//
//        //======================
//        case .PROX:
//            let proximitUpdate = newValue as! Int16
//            environmentDelegate?.proximityUpdated(to: proximitUpdate)
//            stidgetParamtervalues.prox  = proximitUpdate
//
//        //======================
//        case .RPM:
//            let rpmUpdate = newValue as! UInt16
//            motionDelegate?.rpmUpdated(to: rpmUpdate)
//            stidgetParamtervalues.rpm = rpmUpdate
//
//        //======================
//        case .TEMP:
//            let temperatureUpdate = newValue as! Int16
//            environmentDelegate?.temperatureUpdated(to: temperatureUpdate)
//            stidgetParamtervalues.temperature = temperatureUpdate
//        }
//    }
//
//
//
//
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
