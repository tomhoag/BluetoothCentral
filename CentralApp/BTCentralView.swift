//
//  ContentView.swift
//  iOSCentral
//
//  Created by Tom on 6/16/21.
//

import SwiftUI

struct BTCentralView: View {
    
    @EnvironmentObject var btcentral:BTCentralManager
    @State private var msg:String = ""
    
    var isAppClip:Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            Text(isAppClip ? "BLE Central App Clip" : "BLE Central App")
                .font(.largeTitle)
            
            Color(.sRGB, red: btcentral.redValue, green: btcentral.greenValue, blue: btcentral.blueValue, opacity: 1.0)
                .frame(width: 200, height: 200, alignment: .center)
                .border(Color(.sRGB,
                              red: 1 - btcentral.redValue,
                              green: 1 - btcentral.greenValue,
                              blue: 1 - btcentral.blueValue,
                              opacity: 1.0),
                        width: 1)
                .padding()
            
            VStack {
                Slider(
                    value: $btcentral.redValue,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            btcentral.write(uuid: BTPeripheralManager.redCharacteristicUUID)
                        }
                    }){
                    Text("red")
                }
                .accentColor(Color(.sRGB, red: btcentral.redValue, green: 0.0, blue: 0.0, opacity: 1.0))
                .disabled(!btcentral.redReady)
                
                Text(String(format: "red: %1.2f", btcentral.redValue))
            }
            
            VStack {
                Slider(
                    value: $btcentral.greenValue,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            btcentral.write(uuid: BTPeripheralManager.greenCharacteristicUUID)
                        }
                    }){
                    Text("green")
                }
                .accentColor(Color(.sRGB, red: 0.0, green: btcentral.greenValue, blue: 0.0, opacity: 1.0))
                .disabled(!btcentral.greenReady)

                Text(String(format: "green: %1.2f", btcentral.greenValue))
            }
            
            VStack {
                Slider(
                    value: $btcentral.blueValue,
                    in: 0...1,
                    onEditingChanged: { editing in
                        if !editing {
                            btcentral.write(uuid: BTPeripheralManager.blueCharacteristicUUID)
                        }
                    }){
                    Text("blue")
                }
                .accentColor(Color(.sRGB, red: 0.0, green: 0.0, blue: btcentral.blueValue, opacity: 1.0))
                .disabled(!btcentral.blueReady)
                
                Text(String(format: "blue: %1.2f", btcentral.blueValue))
            }
            
            Spacer()
//            Text(btcentral.statusMessage)
//            Text(btcentral.deviceMessage)
        }
        .padding()
    }
}

struct CentralView_Previews: PreviewProvider {
    static var previews: some View {
        BTCentralView(isAppClip: false).environmentObject(BTCentralManager())
    }
}
