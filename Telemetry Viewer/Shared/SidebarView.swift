//
//  SidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.08.20.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var api: APIRepresentative
    @Binding var selectedApp: TelemetryApp?
    
    var body: some View {
        List(selection: $selectedApp) {
            
            Section(header: Text("Apps")) {
            
                ForEach(Array(api.apps), id: \.self) { app in
                    
                    NavigationLink(
                        destination: TelemetryAppView(api: api, app: app),
                        label: {
                            Label(app.name, systemImage: "app.badge")
                        }
                    )
                }
            }
        }.listStyle(SidebarListStyle())
    }
}
