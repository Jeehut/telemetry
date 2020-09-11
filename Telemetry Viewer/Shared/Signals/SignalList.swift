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
    
    var body: some View {
        List {
            if api.signals[app] == nil || api.signals[app]!.isEmpty {
                ForEach(MockData.signals, id: \.self) { signal in
                    SignalView(signal: signal).redacted(reason: .placeholder)
                }
            } else {
                ForEach(api.signals[app]!, id: \.self) { signal in
                    SignalView(signal: signal)
                }
            }
        }
        .onAppear {
            api.getSignals(for: app)
            TelemetryManager().send(.telemetryAppSignalsShown, for: api.user?.email ?? "unregistered user")
        }
    }
}

struct SignalList_Previews: PreviewProvider {
    static var previews: some View {
        SignalList(app: MockData.app1)
    }
}
