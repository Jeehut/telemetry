//
//  SignalList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct SignalList: View {
    let signals: [Signal]
    
    var body: some View {
        List {
            ForEach(signals, id: \.self) { signal in
                    SignalView(signal: signal)
            }
        }
        
    }
}

struct SignalList_Previews: PreviewProvider {
    static var previews: some View {
        let signals = APIRepresentative().allSignals[app1]!
        
        SignalList(signals: signals)
    }
}
