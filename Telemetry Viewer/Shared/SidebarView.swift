//
//  SidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.08.20.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var store: SignalStore
    @Binding var selectedApp: TelemetryApp?
    
    var body: some View {
        List(selection: $selectedApp) {
            
            Section(header: Text("Apps")) {
            
                ForEach(Array(store.allApps), id: \.self) { app in
                    
                    NavigationLink(
                        destination: TelemetryAppView(store: store, app: app),
                        label: {
                            Label(app.name, systemImage: "dot.radiowaves.left.and.right")        
                        }
                    )
                }
            }
            
            Section(header: Text("Settings")) {
                
            }
        }.listStyle(SidebarListStyle())
    }
}
