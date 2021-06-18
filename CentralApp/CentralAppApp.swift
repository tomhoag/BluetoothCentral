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
            let model = BTCentralManager()
            
            #if APPCLIP
            
            ContentView()
                .environmentObject(model)
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
            
            #else
            
            ContentView()
                .environmentObject(model)
                .onOpenURL(perform: { url in
                    
                    guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
                        return
                    }
                    
                    // TODO do cool app stuff here
                    if let queryItems = components.queryItems,
                       let blueString = queryItems.first(where: { $0.name == "blue" })?.value {
                        model.blueValue = Double(blueString)!
                    }
//                    if let queryItems = components.queryItems,
//                       let scooterId = queryItems.first(where: { $0.name == "id" })?.value {
//                        model.selectedScooter = model.findScooterById(Int(scooterId) ?? 0)
//                    }
                })
            
            #endif
            
        }
    }
    
    #if APPCLIP
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return
        }
        
        // TODO: do cool clip stuff here
        switch components.path {
        case "/help":
            //model.isChatPresented = true
            print("help url")
        case "/colors":
            if let queryItems = components.queryItems,
               let blueString = queryItems.first(where: { $0.name == "blue" })?.value {
                print("colors: \(blueString)")
            }
        default:
            break
        }
    }
    #endif
}
