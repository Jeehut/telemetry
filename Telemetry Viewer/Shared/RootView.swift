//
//  RootView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 04.09.20.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var api: APIRepresentative
    @State private var selectedApp: TelemetryApp?
    @State var showingDetail = true
    
    var body: some View {
        NavigationView {
            SidebarView(selectedApp: $selectedApp)
            Text("Please Select an App")
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .sheet(isPresented: $showingDetail, onDismiss: { showingDetail = true }) {
            
            NavigationView {
                WelcomeView()
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
