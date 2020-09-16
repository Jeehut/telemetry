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
        let saveButtons =
            HStack {
                Button("Save") {
                    api.create(userCountGroup: userCountGroupCreateRequestBody, for: app)
                    isPresented = false
                }
                
                Button("Cancel") {
                    isPresented = false
                }
            }
        
        let form = Form {
            #if os(macOS)
            Text("New User Count Group")
                .font(.title2)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
            #endif
            
            Text("User Count Groups are a named request to Telemetry to count and graph users over a specific time frame.")
            
            Section(header: Text("New User Count Group")) {
                TextField("Title", text: $userCountGroupCreateRequestBody.title)
            }
            
            Section(header: Text("Time Frame")) {
                Text("How many seconds should we go backwards in time to look for users?")
                
                HStack {
                    TextField("Time Frame", value: $userCountGroupCreateRequestBody.timeInterval, formatter: NumberFormatter())
                    Button("1 Hour") { userCountGroupCreateRequestBody.timeInterval = -3600 }
                    Button("A day") { userCountGroupCreateRequestBody.timeInterval = -3600*24 }
                    Button("A Week") { userCountGroupCreateRequestBody.timeInterval = -3600*24*7 }
                    Button("30 Days") { userCountGroupCreateRequestBody.timeInterval = -3600*24*30 }
                }
                
                let calculatedAt = Date()
                let calculationBeginDate = Date(timeInterval: userCountGroupCreateRequestBody.timeInterval, since: calculatedAt)
                let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
                Text("Look at the last \(dateComponentsFormatter.string(from: dateComponents) ?? "—")").bold()
                
                #if os(macOS)
                saveButtons
                #endif
            }
        }
        
        #if os(macOS)
        form
            .padding()
        #else
        NavigationView {
            form
                .navigationTitle("New User Count Group")
                .navigationBarItems(trailing: saveButtons)
        }
        #endif
        
    }
}

//struct NewUserCountGroupForm_Previews: PreviewProvider {
//    static var previews: some View {
//        NewUserCountGroupForm( isPresented: <#Binding<Bool>#>, app: MockData.app1)
//            .previewDevice("iPad Pro (9.7-inch)")
//    }
//}
