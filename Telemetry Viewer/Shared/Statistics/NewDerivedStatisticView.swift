//
//  NewUserCountGroupForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.09.20.
//

import SwiftUI

struct NewDerivedStatisticView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    var derivedStatisticGroup: DerivedStatisticGroup
    
    @State var derivedStatisticCreateRequestBody: DerivedStatisticCreateRequestBody = DerivedStatisticCreateRequestBody(title: "System Version", payloadKey: "systemVersion")
    
    var body: some View {
        let saveButton = Button("Save") {
            api.create(derivedStatistic: derivedStatisticCreateRequestBody, for: derivedStatisticGroup, in: app)
            isPresented = false
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") {
            isPresented = false
        }
        .keyboardShortcut(.cancelAction)
        
        let form = Form {
            #if os(macOS)
            Text("New Derived Statistic")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif
            
            Section(header: Text("New Derived Statistic"), footer: Text("Derived Statistics Need a human readable Name, e.g. 'System Version'")) {
                TextField("Title", text: $derivedStatisticCreateRequestBody.title)
            }
            
            Section(header: Text("Payload Key"), footer: Text("The key being counted, e.g. 'systemVersion'.")) {
                TextField("Title", text: $derivedStatisticCreateRequestBody.payloadKey)
            }
            
            #if os(macOS)
            HStack {
                cancelButton
                Spacer()
                saveButton
            }
            #endif
            
        }
        
        #if os(macOS)
        form
            .padding()
        #else
        NavigationView {
            form
                .navigationTitle("New Derived Statistic")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        #endif
        
    }
}
