//
//  UserCountListView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 31.08.20.
//

import SwiftUI

struct UserCountGroupView: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    @State var isShowingCreateUserCountGroupView = false
    @State var userCountGroupCreateRequestBody: UserCountGroupCreateRequestBody = UserCountGroupCreateRequestBody(title: "Active Users", timeInterval: -3600*24)
    let timer = Timer.publish(every: 10, on: .current, in: .common).autoconnect()
    
    let columns = [
        GridItem(.adaptive(minimum: 250))
    ]
    
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                if api.userCountGroups[app] != nil {
                    ForEach(api.userCountGroups[app]!) { userCountGroup in
                        ZStack(alignment: Alignment.topTrailing) {
                            UserCountView(userCountGroup: userCountGroup)
                            
                            Button(
                                action: { api.delete(userCountGroup: userCountGroup, from: app) },
                                label: {
                                    Image(systemName: "xmark.circle.fill")
                                })
                                .offset(x: -10, y: 10)
                        }
                    }
                    
                    CardView {
                        Button(action: { isShowingCreateUserCountGroupView = true }, label: { Label("Create New", systemImage: "rectangle.badge.plus") })
                    }
                } else {
                    ForEach(MockData.userCounts, id: \.self) { userCountGroup in
                        UserCountView(userCountGroup: userCountGroup).redacted(reason: .placeholder)
                    }
                }
                
            }
            .padding(.horizontal)
            
            if api.userCountGroups[app] != nil && !api.userCountGroups[app]!.isEmpty {
                LazyVGrid(columns: [GridItem(.flexible()),], spacing: 20) {
                    CardView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 30))], alignment: .leading) {
                            ForEach(api.userCountGroups[app]!) { userCountGroup in
                                Section(header: Text(userCountGroup.title).font(.title3)) {
                                    ForEach(userCountGroup.data, id: \.self) { userCount in
                                        Text("\(userCount.count)").font(.system(.body, design: .monospaced))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            api.getUserCountGroups(for: app)
            TelemetryManager().send(.telemetryAppUsersShown, for: api.user?.email ?? "unregistered user")
        }
        .onReceive(timer) { timer in
            api.getUserCountGroups(for: app)
        }
        .sheet(isPresented: $isShowingCreateUserCountGroupView) {
            Form {
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
                    
                    
                    HStack {
                        Button("Save") {
                            api.create(userCountGroup: userCountGroupCreateRequestBody, for: app)
                            isShowingCreateUserCountGroupView = false
                        }
                        
                        Button("Cancel") {
                            isShowingCreateUserCountGroupView = false
                        }
                    }
                }
            }
            .padding()
        }
        
        .toolbar {
            ToolbarItem {
                Button(action: {
                    isShowingCreateUserCountGroupView = true
                }) {
                    Label("New User Count Group", systemImage: "rectangle.badge.plus")
                }
                
            }
        }
        
    }
}
