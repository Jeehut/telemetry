//
//  SignalList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct SignalList: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    
    var signals: [Signal] {
        return api.signals[app, default: MockData.signals]
    }
    
    var body: some View {
        List {
            ForEach(signals, id: \.self) { signal in
                if signal.isMockData {
                    SignalView(signal: signal).redacted(reason: .placeholder)
                } else {
                    SignalView(signal: signal)
                }
            }
        }
    }
}

struct SignalList_Previews: PreviewProvider {
    static var previews: some View {
        SignalList(app: MockData.app1)
    }
}
