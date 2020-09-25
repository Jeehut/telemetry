//
//  NewUserCountGroupForm.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 16.09.20.
//

import SwiftUI

struct NewUserCountGroupForm: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    
    @State var userCountGroupCreateRequestBody: UserCountGroupCreateRequestBody = UserCountGroupCreateRequestBody(title: "Active Users", timeInterval: -3600*24)
    
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        let saveButton = Button("Save") {
            api.create(userCountGroup: userCountGroupCreateRequestBody, for: app)
            isPresented = false
        }
        .keyboardShortcut(.defaultAction)
        
        let cancelButton = Button("Cancel") {
            isPresented = false
        }
        .keyboardShortcut(.cancelAction)
        
        let form = Form {
            #if os(macOS)
            Text("New User Count Group")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif
            
            Section(header: Text("New User Count Group"), footer: Text("User Count Groups are a named request to Telemetry to count and graph users over a specific time frame.")) {
                TextField("Title", text: $userCountGroupCreateRequestBody.title)
            }
            
            Section(header: Text("Time Frame"), footer: VStack(alignment: .leading) {
                
                let calculatedAt = Date()
                let calculationBeginDate = Date(timeInterval: userCountGroupCreateRequestBody.timeInterval, since: calculatedAt)
                let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
                
                Text("How many seconds should we go backwards in time to look for users?")
                Text("\(NumberFormatter().string(for: userCountGroupCreateRequestBody.timeInterval) ?? "-") seconds equals \(dateComponentsFormatter.string(from: dateComponents) ?? "—") back in time.").bold()
            }) {
                
                TextField("Time Frame", value: $userCountGroupCreateRequestBody.timeInterval, formatter: NumberFormatter())
                
                Button("Set to 1 Hour") { userCountGroupCreateRequestBody.timeInterval = -3600 }
                Button("Set to A day") { userCountGroupCreateRequestBody.timeInterval = -3600*24 }
                Button("Set to A Week") { userCountGroupCreateRequestBody.timeInterval = -3600*24*7 }
                Button("Set to 30 Days") { userCountGroupCreateRequestBody.timeInterval = -3600*24*30 }
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
                .navigationTitle("New User Count Group")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        #endif
        
    }
}
