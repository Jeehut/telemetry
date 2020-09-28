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
            return "Insights"
        case 1:
            return "Users"
        case 2:
            return "Statistics"
        case 3:
            return "Funnels"
        case 4:
            return "Signals"
        default:
            return "Omsn"
        }
    }
    
    #if os(macOS)
    let paddingAmount: CGFloat = 16
    #else
    let paddingAmount: CGFloat = 0
    #endif
    
    var body: some View {
        TabView(selection: $selectedView) {
            InsightGroupList(app: app)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Insights")
                }.tag(0)
            UserCountGroupView(app: app)
                .tabItem {
                    Image(systemName: "person.2.square.stack")
                    Text("Users")
                }.tag(1)
            StatisticsView(app: app)
                .tabItem {
                    Image(systemName: "chart.pie")
                    Text("Statistics")
                }.tag(2)
            Text("Funnels")
                .tabItem {
                    Image(systemName: "arrowtriangle.down.square")
                    Text("Funnels")
                }.tag(3)
            SignalList(app: app)
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Signals")
                }.tag(4)
        }
        .navigationTitle(calculatedNavigationTitle)
        .padding(paddingAmount)
    }
}
