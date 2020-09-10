//
//  NewAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 07.09.20.
//

import SwiftUI

struct NewAppView: View {
    @EnvironmentObject var api: APIRepresentative
    @Environment(\.presentationMode) var presentationMode
    @State var newAppName: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Create a new App.")
            TextField("Name", text: $newAppName)
            Text("When you're done, press the save button to create the new app.")
            
            #if os(macOS)
            HStack {
                Button("Save") {
                    api.create(appNamed: newAppName)
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
            #endif
        }
        .padding()
        .navigationTitle("New App")
        
        #if os(macOS)
        #else
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    api.create(appNamed: newAppName)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        #endif
    }
}
