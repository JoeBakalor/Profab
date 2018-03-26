//
//  GattDelegate.swift
//  WicedWiFiIntroducer
//
//  Created by Joe Bakalor on 2/12/18.
//  Copyright © 2018 bluth. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol GattDelegate{
    func foundServices(services: [CBService])
    func foundCharacteristics(characteristics: [CBCharacteristic])
}
