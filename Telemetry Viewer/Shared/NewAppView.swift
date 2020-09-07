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
        }
        .padding()
        .navigationTitle("New App")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    api.create(appNamed: newAppName)
                    self.presentationMode.wrappedValue.dismiss()

                }
            }
        }
    }
}
