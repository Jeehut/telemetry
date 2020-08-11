//
//  TelemetryAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct TelemetryAppView: View {
    @ObservedObject var store: SignalStore
    var app: TelemetryApp
    
    var body: some View {
        List {
            
            NavigationLink(
                destination: SignalList(signals: store.allSignals[app]!),
                label: {
                    Label("Raw Signals", systemImage: "waveform.path.ecg.rectangle")
                }
            )
        }.navigationBarTitle(Text(app.name))
    }
}
