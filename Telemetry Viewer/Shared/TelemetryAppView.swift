//
//  TelemetryAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct TelemetryAppView: View {
    @EnvironmentObject var api: APIRepresentative
    @State var selectedView = 0
    var app: TelemetryApp
    @State var isCreatingANewApp: Bool = false
    
    var calculatedNavigationTitle: String {
        switch selectedView {
        case 0:
            return "Users"
        case 1:
            return "Statistics"
        case 2:
            return "Funnels"
        case 3:
            return "Signals"
        default:
            return "Omsn"
        }
    }
    
    var body: some View {
        TabView(selection: $selectedView) {
            UserCountGroupView(app: app)
                .tabItem {
                    Image(systemName: "person.2.square.stack")
                    Text("Users")
                }.tag(0)
            StatisticsView(app: app)
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Statistics")
                }.tag(1)
            Text("Funnels")
                .tabItem {
                    Image(systemName: "arrowtriangle.down.square")
                    Text("Funnels")
                }.tag(2)
            SignalList(app: app)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Signals")
                }.tag(3)
        }
        .navigationTitle(calculatedNavigationTitle)
    }
}
