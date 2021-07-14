//
//  BTCentralManager.swift
//  iOSCentral
//
//  Created by Tom on 6/16/21.
//

import Foundation
import CoreBluetooth

public class BTCentralManager: NSObject, ObservableObject {
    
    @Published var deviceMessage:String!
    @Published var statusMessage:String!
    
    @Published var launchQueryItem:String = "unknown"
    
    private var centralManager:CBCentralManager!
    private var peripheral:CBPeripheral!
    
    private var redChar: CBCharacteristic?
    private var greenChar: CBCharacteristic?
    private var blueChar: CBCharacteristic?
    
    private var trackInfoChar:CBCharacteristic?
    private var trackAlbumArtChar:CBCharacteristic?
    

    @Published var redValue:Double = 0
    @Published var greenValue:Double = 0
    @Published var blueValue:Double = 0
    
    @Published var trackInfo:SpotifyTrackInfo = SpotifyTrackInfo(title: "--", artist: "--", album: "--", position: 0, duration: 0)
    @Published var trackAlbumArt:SpotifyAlbumArt = SpotifyAlbumArt()
    
    var imageData = Data()
    
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
        
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            statusMessage = "connected to peripheral"
            peripheral.discoverServices([BTPeripheralManager.serviceUUID])
            
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
                          BTPeripheralManager.blueCharacteristicUUID,
                          SpotifyTrackInfo.characteristicUUID,
                          SpotifyAlbumArt.characteristicUUID
                        ], for: service)
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
                    
                } else if characteristic.uuid == SpotifyTrackInfo.characteristicUUID {
                    statusMessage = "trackInfo characteristic found"
                    trackInfoChar = characteristic
                    peripheral.readValue(for:trackInfoChar!)
                    
                    peripheral.setNotifyValue(true, for: trackInfoChar!)
                 
                } else if characteristic.uuid == SpotifyAlbumArt.characteristicUUID {
                    statusMessage = "trackAlbumArt characteristic found"
                    trackAlbumArtChar = characteristic
                    //peripheral.readValue(for:trackAlbumArtChar!)
                    
                    peripheral.setNotifyValue(true, for: trackAlbumArtChar!)
                    
                } else {
                    print("tf? \(characteristic.uuid)")
                }
                print("DeviceMessage: \(deviceMessage ?? "")")
                print("StatusMessage: \(statusMessage ?? "")")
            }
            deviceMessage = ""
            
        }
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        print("Error changing notification state: \(error?.localizedDescription)")
//        
//        // Exit if it's not the transfer characteristic
//        guard characteristic.uuid.isEqual(transferCharacteristicUUID) else {
//            return
//        }
//        
//        // Notification has started
//        if (characteristic.isNotifying) {
//            print("Notification began on \(characteristic)")
//        } else { // Notification has stopped
//            print("Notification stopped on (\(characteristic))  Disconnecting")
//            centralManager?.cancelPeripheralConnection(peripheral)
//        }
//    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard (error == nil) else {
            deviceMessage = "error reading characteristic"
            print("didUpdateValueFor", error.debugDescription)
            print("DeviceMessage: \(deviceMessage ?? "")")
            print("StatusMessage: \(statusMessage ?? "")")
            return
        }
        
        DispatchQueue.global(qos: .background).async { [self] in
            if let data = characteristic.value {
                if self.isColorCharacteristicUUID(characteristic.uuid), let double = data.to(type: Double.self) {
                    switch characteristic.uuid {
                    case BTPeripheralManager.redCharacteristicUUID:
                        self.redValue = double
                    case BTPeripheralManager.greenCharacteristicUUID:
                        self.greenValue = double
                    case BTPeripheralManager.blueCharacteristicUUID:
                        self.blueValue = double
                    default:
                        print("unknown double char")
                    }
                    self.statusMessage = "read peripheral"
                    
                } else if characteristic == self.trackInfoChar {
                    
                    if let spotifyTrackInfo = SpotifyTrackInfo.fromData(data) {
                        
                        DispatchQueue.main.async {
                            self.trackInfo = SpotifyTrackInfo(
                                title: spotifyTrackInfo.title,
                                artist: spotifyTrackInfo.artist,
                                album: spotifyTrackInfo.album,
                                position: spotifyTrackInfo.position,
                                duration: spotifyTrackInfo.duration
                            )
                        }
                    }
                    
                } else if characteristic == self.trackAlbumArtChar {
                    
                    let stringFromData = String(decoding: characteristic.value!, as: UTF8.self)
                    
                    // Have we got everything we need?
                    if stringFromData.isEqual("EOM") {
                        
                        print("received EOM")
                        // We have, so show the data,
                        DispatchQueue.main.async {
                            self.trackAlbumArt.imageData = self.imageData
                            self.imageData = Data()
                        }
                    } else {
                        // Otherwise, just add the data on to what we already have
                        self.imageData.append(characteristic.value!)
                        
                        // Log it
//                        print("Received: \(stringFromData)")
                        print("received: \(self.imageData.count)")
                    }
                    
                } else {
                    print("didUpdateValueFor recd unknown charateristic??")
                }
            }
        }
    }
    
    private func isColorCharacteristicUUID(_ uuid:CBUUID) -> Bool {
        
        return [BTPeripheralManager.redCharacteristicUUID, BTPeripheralManager.greenCharacteristicUUID, BTPeripheralManager.blueCharacteristicUUID].contains(uuid)
        
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
                
                
            }
        }
    }
}
