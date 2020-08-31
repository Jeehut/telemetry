//
//  Telemetry_ViewerApp.swift
//  Shared
//
//  Created by Daniel Jilg on 30.07.20.
//

import SwiftUI

@main
struct Telemetry_ViewerApp: App {
    @StateObject var api = APIRepresentative()
    @State private var selectedApp: TelemetryApp?
    
    var body: some Scene {
        WindowGroup {
            
            NavigationView {
                SidebarView(api: api, selectedApp: $selectedApp)
                Text("Please Select an App")
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}
