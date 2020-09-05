//
//  SidebarView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.08.20.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var api: APIRepresentative
    @Binding var selectedApp: TelemetryApp?
    
    var body: some View {
        List(selection: $selectedApp) {
            
            Section(header: Text("Apps")) {
            
                ForEach(Array(api.apps), id: \.self) { app in
                    if app.isExampleData {
                        
                        NavigationLink(
                            destination: TelemetryAppView(app: app),
                            label: {
                                Label(app.name, systemImage: "app.badge")
                            }
                        )
                        .redacted(reason: .placeholder)
                    } else {
                        NavigationLink(
                            destination: TelemetryAppView(app: app),
                            label: {
                                Label(app.name, systemImage: "app.badge")
                            }
                        )
                    }
                }
            }
            
            Section(header: Text("Organization")) {
                if let apiUser = api.user {
                    Label(apiUser.organization.name, systemImage: "app.badge")
                } else {
                    Label("organization.name", systemImage: "app.badge").redacted(reason: .placeholder)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("All Apps")
    }
}
