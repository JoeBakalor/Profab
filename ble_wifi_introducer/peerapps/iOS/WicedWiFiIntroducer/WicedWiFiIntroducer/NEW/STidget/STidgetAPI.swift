//
//  STidgetAPI.swift
//  STidget
//
//  Created by Joe Bakalor on 11/30/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

//STIDGET PARAMETER ENUMERATION
enum STidgetParameters {
    case RPM
    case TEMP
    case ACCEL
    case GYRO
    case PROX
    case LIGHT
    case LED
}

//STIDGET STATUS'S ENUM
enum STidgetStatus {
    case searching
    case found
    case idle
    case unknown
    case connecting
    case connected
}

//TOP LEVEL STIDGET DELEGATE PROTOCOL
@objc protocol stidgetDelegate{
    @objc optional func connected()
    @objc optional func disconnected()
    @objc optional func connectionFailed()
}

protocol STidgetDeviceManager: stidgetDelegate{
    func foundStidget()
}

//LED DELEGATE PROTOCOL
protocol ledServiceDelegate: stidgetDelegate{
    func ledColorUpdated()
}

//USED BY DATA MODELS TO INFORM VIEW CONTROLLERS OF DISCONNECTIONS
protocol STidgetConnectionFailureDelegate{
    func stidgetConnectionFailed()
}

//ENVIRONMENTAL SERVICE DELEGATE PROTOCOL
protocol environmentalServiceDelegate: stidgetDelegate {
    func temperatureUpdated(to temp: Int16)
    func lightLevelUpdated(to lightLevel: UInt16)
    func proximityUpdated(to distance: Int16)
}

//MOTION SERVICE DELEGATE PROTOCOL
protocol motionServiceDelegate: stidgetDelegate {
    func rpmUpdated(to rpm: UInt16)
    func accelerometerUpdated(to x: Int16, y: Int16, z: Int16)
    func gyroUpdated(to x: Int16, y: Int16, z: Int16)
}

//DEFINE PROTOCOL FOR EXPOSING STIDGET API METHODS
protocol STidgetAPI {
    
    func getSTidgetStatus() -> STidgetStatus
    func setLedDelegate(Delegate: ledServiceDelegate?)
    func setEnvironmentalDelegate(Delegate: environmentalServiceDelegate?)
    func setDisconnectionDelegate(delegate: STidgetConnectionFailureDelegate?)
    func discover()
    func connect()
    func disconnect()
    func rpm() -> (UInt16)
    func temperature() -> (Int16)
    func acceleration() -> (x: Int16, y: Int16, z: Int16)
    func gyroscope() -> (x: Int16, y: Int16, z: Int16)
    func proximity() -> (Int16)
    func ambientLightLevel() -> (UInt16)
    func setLedColor(red: UInt8, green: UInt8, blue: UInt8)
}

//CONNECTION TO LOWER LEVEL BLE
protocol STidgetAPIDelegate: stidgetDelegate {
    func foundSTidgetPeripheral(StidgetPeripheral: CBPeripheral)
    func updatedParameter(for parameter: STidgetParameters, newValue: Any)
}


