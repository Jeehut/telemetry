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
    
    var appIDString: String {
        guard let appId = app.id else {
            return "No App ID"
        }
        
        return appId.uuidString
    }
    
    var body: some View {
            VStack {
                Text("App Settings")
                TextField("", text: .constant(appIDString))
                TextField("App Name", text: $newName)
                
                Button("Update App Name") {
                    api.update(app: app, newName: newName)
                    self.presentationMode.wrappedValue.dismiss()
                    TelemetryManager().send(.telemetryAppUpdated, for: api.user?.email ?? "unregistered user")
                }
                
                Button("Delete App") {
                    api.delete(app: app)
                    self.presentationMode.wrappedValue.dismiss()
                    TelemetryManager().send(.telemetryAppDeleted, for: api.user?.email ?? "unregistered user")
                }
                
                Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                }
                
                
            }
            .padding()
        
        .onAppear {
            newName = app.name
            TelemetryManager().send(.telemetryAppSettingsShown, for: api.user?.email ?? "unregistered user")
        }
    }
}

struct EditAppView_Previews: PreviewProvider {
    static var previews: some View {
        AppSettingsView(app: MockData.app1)
    }
}
