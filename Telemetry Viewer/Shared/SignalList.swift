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
            Text("Here's a list of raw signals received for this app.")
            ForEach(signals, id: \.self) { signal in
                SignalView(signal: signal)
            }
        }
    }
}

struct SignalList_Previews: PreviewProvider {
    static var previews: some View {
        let signals = APIRepresentative().signals[app1]!
        
        SignalList(signals: signals)
    }
}
