//
//  CentralAppApp.swift
//  CentralApp
//
//  Created by Tom on 6/17/21.
//

import SwiftUI

@main
struct CentralAppApp: App {
    var body: some Scene {
        WindowGroup {
            BTCentralView().environmentObject(BTCentralManager())
        }
    }
}
