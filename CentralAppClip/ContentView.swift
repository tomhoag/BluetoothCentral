//
//  ContentView.swift
//  CentralAppClip
//
//  Created by Tom on 6/17/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var btcentral:BTCentralManager
        
    var body: some View {
        BTCentralView(isAppClip: true).environmentObject(btcentral)
            .tabItem {
                Label("BT", systemImage: "network")
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BTCentralManager())
    }
}
