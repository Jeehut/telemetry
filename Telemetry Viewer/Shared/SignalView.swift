//
//  SignalView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct SignalView: View {
    var signal: Signal
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Label {
            HStack(alignment: .top) {
                
                
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(signal.type).bold()
                        Text("received at")
                        Text(dateFormatter.string(from: signal.receivedAt))
                    }
                    
                    HStack {
                        Text("From")
                        Text(signal.app.name)
                        Text("user")
                        Text(signal.clientUser).bold()
                    }
                }
                
                Text(signal.payload?.debugDescription ?? "No Payload").foregroundColor(.gray)
            }
        } icon: {
            Image(systemName: "waveform")
        }
        
        
    }
}

struct SignalView_Previews: PreviewProvider {
    static var previews: some View {
        let signal: Signal = .init(id: UUID(), app: app1, receivedAt: Date(), clientUser: "randomClientUser", type: "ExampleSignal", payload: ["systemVersion": "14.0", "isSimulator": "false"])
        SignalView(signal: signal)
    }
}
