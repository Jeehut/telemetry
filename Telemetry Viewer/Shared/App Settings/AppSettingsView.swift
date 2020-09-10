//
//  EditAppView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 10.09.20.
//

import SwiftUI

struct AppSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    @State var newName: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("App Settings")
                TextField("App Name", text: $newName)
                
                Button("Update App Name") {
                    api.update(app: app, newName: newName)
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                Button("Delete App") {
                    api.delete(app: app)
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                
            }
            .padding()
        }
        .onAppear {
            newName = app.name
        }
    }
}

struct EditAppView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView(app: MockData.app1)
    }
}
