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
    @State var isCreatingANewApp: Bool = false
    
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
            
            Section(header: Text("You")) {
                
                if let apiUser = api.user {
                    
                    NavigationLink(destination: UserSettingsView(), label: {
                        Label("\(apiUser.firstName) \(apiUser.lastName)", systemImage: "person.circle")
                    })
                    
                    
                    NavigationLink(destination: OrganizationSettingsView(), label: {
                        Label(apiUser.organization.name, systemImage: "app.badge")
                    })
                } else {
                    Label("firstName lastName", systemImage: "person.circle").redacted(reason: .placeholder)
                    Label("organization.name", systemImage: "app.badge").redacted(reason: .placeholder)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("All Apps")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        isCreatingANewApp = true
                    }) {
                        Label("New App", systemImage: "plus.app.fill")
                    }
                    .sheet(isPresented: $isCreatingANewApp) {
                        NavigationView {
                            NewAppView()
                        }
                    }
                }
            }
        }
    }
}
