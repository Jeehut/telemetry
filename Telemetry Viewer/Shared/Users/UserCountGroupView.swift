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
    @State var userCountGroupCreateRequestBody: UserCountGroupCreateRequestBody = UserCountGroupCreateRequestBody(title: "New User Count", timeInterval: -3600*24)
    
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.adaptive(minimum: 250))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                if api.userCountGroups[app] != nil {
                    ForEach(api.userCountGroups[app]!) { userCountGroup in
                        UserCountView(userCount: userCountGroup.data.first ?? UserCount(count: 0, calculatedAt: Date()), descriptionText: userCountGroup.title, timeInterval: userCountGroup.timeInterval)
                    }
                    
                    CardView {
                        
                        Button("Create New") {
                            isShowingCreateUserCountGroupView = true
                        }
                    }
                } else {
                    ForEach(MockData.userCounts, id: \.self) { userCountGroup in
                        
                        UserCountView(userCount: userCountGroup.data.first!, descriptionText: userCountGroup.title, timeInterval: userCountGroup.timeInterval).redacted(reason: .placeholder)
                    }
                }
                
            }
            .padding(.horizontal)
            
            
            LazyVGrid(columns: [GridItem(.flexible()),], spacing: 20) {
                CardView {
                    Text("Graph").frame(height: 300)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            api.getUserCountGroups(for: app)
            TelemetryManager().send(.telemetryAppUsersShown, for: api.user?.email ?? "unregistered user")
        }
        .sheet(isPresented: $isShowingCreateUserCountGroupView) {
            VStack {
                TextField("User Count Group Title", text: $userCountGroupCreateRequestBody.title)
                // TextField("Time Interval (negative!)", text: $userCountGroupCreateRequestBody.timeInterval)
                
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
