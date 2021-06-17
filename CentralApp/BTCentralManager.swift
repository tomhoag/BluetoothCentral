//
//  BTCentralManager.swift
//  iOSCentral
//
//  Created by Tom on 6/16/21.
//

import Foundation
import CoreBluetooth
import SwiftUI

public class BTCentralManager: NSObject, ObservableObject {
    
    @Published var deviceMessage:String!
    @Published var statusMessage:String!
    
    @Published var launchQueryItem:String = "unknown"
    
    private var centralManager:CBCentralManager!
    private var peripheral:CBPeripheral!
    
    private var redChar: CBCharacteristic?
    private var greenChar: CBCharacteristic?
    private var blueChar: CBCharacteristic?

    @Published var redValue:Double = 0
    @Published var greenValue:Double = 0
    @Published var blueValue:Double = 0
    
    @Published var redReady = false
    @Published var greenReady = false
    @Published var blueReady = false
    
    public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        statusMessage = ""
        deviceMessage = "Woot!"
    }
    
    public func write(uuid:CBUUID, value:Double = 0) {

        guard peripheral != nil else {
            print("write failed; not connected")
            return
        }
        
        switch uuid {
        case BTPeripheralManager.redCharacteristicUUID:
            peripheral.writeValue(Data(from: redValue), for:redChar!, type: .withoutResponse)
        case BTPeripheralManager.greenCharacteristicUUID:
            peripheral.writeValue(Data(from: greenValue), for:greenChar!, type: .withoutResponse)
        case BTPeripheralManager.blueCharacteristicUUID:
            peripheral.writeValue(Data(from: blueValue), for:blueChar!, type: .withoutResponse)
        default:
            print("CM skipped write")
        }        
    }
}

extension BTCentralManager: CBCentralManagerDelegate {
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        redReady = false
        greenReady = false
        blueReady = false
        
        deviceMessage = "scanning for \(BTPeripheralManager.serviceUUID)"
        centralManager.scanForPeripherals(withServices: [BTPeripheralManager.serviceUUID],
                                          options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            deviceMessage = "not powered on"
        } else {
            deviceMessage = "scanning for \(BTPeripheralManager.serviceUUID)"
            centralManager.scanForPeripherals(withServices: [BTPeripheralManager.serviceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // We've found it so stop scan
        self.centralManager.stopScan()
        
        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self
        
        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
        
        deviceMessage = ""
        statusMessage = "disovered peripheral"
        print(deviceMessage ?? "", statusMessage ?? "")
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            statusMessage = "connected to peripheral"
            peripheral.discoverServices([BTPeripheralManager.serviceUUID])
            
            print(deviceMessage ?? "", statusMessage ?? "")

        }
    }
    
}

extension BTCentralManager: CBPeripheralDelegate {
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == BTPeripheralManager.serviceUUID {
                    statusMessage = "service found"
                    deviceMessage = "discovering characteristics"
                    
                    print(deviceMessage ?? "", statusMessage ?? "")

                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics(
                        [ BTPeripheralManager.redCharacteristicUUID,
                          BTPeripheralManager.greenCharacteristicUUID,
                          BTPeripheralManager.blueCharacteristicUUID], for: service)
                    return
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == BTPeripheralManager.redCharacteristicUUID {
                    statusMessage = "red characteristic found"
                    redChar = characteristic
                    redReady = true
                    peripheral.readValue(for: characteristic)
                    
                } else if characteristic.uuid == BTPeripheralManager.greenCharacteristicUUID {
                    statusMessage = "green characteristic found"
                    greenChar = characteristic
                    greenReady = true
                    peripheral.readValue(for: characteristic)
                    
                } else if characteristic.uuid == BTPeripheralManager.blueCharacteristicUUID {
                    statusMessage = "blue characteristic found"
                    blueChar = characteristic
                    blueReady = true
                    peripheral.readValue(for: characteristic)
                } else {
                    print("tf? \(characteristic.uuid)")
                }
                print(deviceMessage ?? "", statusMessage ?? "")
            }
            deviceMessage = ""
            

        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard (error == nil) else {
            deviceMessage = "error reading characteristic"
            print(deviceMessage ?? "", statusMessage ?? "")

            return
        }
        if let data = characteristic.value {
            if let double = data.to(type: Double.self) {
                switch characteristic.uuid {
                case BTPeripheralManager.redCharacteristicUUID:
                    redValue = double
                case BTPeripheralManager.greenCharacteristicUUID:
                    greenValue = double
                case BTPeripheralManager.blueCharacteristicUUID:
                    blueValue = double
                default:
                    print("unknown char")
                }
                statusMessage = "read peripheral"
                print(deviceMessage ?? "", statusMessage ?? "")
                
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        guard (error == nil) else {
            deviceMessage = "error reading from peripheral"
             return
        }
        
        if let data = descriptor.value as? Data {
            if let double = data.to(type: Double.self) {
                switch descriptor.characteristic.uuid {
                case redChar:
                    redValue = double
                case greenChar:
                    greenValue = double
                case blueChar:
                    blueValue = double
                default:
                    print("unknown char")
                }
                statusMessage = "read peripheral"
                
                print(deviceMessage ?? "", statusMessage ?? "")
                
            }
        }
    }
}
