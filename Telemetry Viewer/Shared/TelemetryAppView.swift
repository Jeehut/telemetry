//
//  TelemetryAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct TelemetryAppView: View {
    @ObservedObject var api: APIRepresentative
    @State var selectedView = 0
    var app: TelemetryApp
    
    var calculatedNavigationTitle: String {
        switch selectedView {
        case 0:
            return "Users"
        case 1:
            return "Insights"
        case 2:
            return "Signals"
        default:
            return "Omsn"

        }
    }
    
    var body: some View {
        
        TabView(selection: $selectedView) {
            UserCountGroupView(userCountGroups: api.userCounts[app]!)
                .tabItem {
                    Image(systemName: "person.2.square.stack")
                    Text("Users")
                }.tag(0)
            Text("Insights")
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Insights")
                }.tag(1)
            SignalList(signals: api.signals[app]!)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Signals")
                }.tag(2)
                
        } .navigationTitle(calculatedNavigationTitle)
        
    }
}
