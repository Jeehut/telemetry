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
    
    let timer = Timer.publish(every: 120, on: .current, in: .common).autoconnect()
    
    let columns = [
        GridItem(.adaptive(minimum: 250))
    ]
    
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
                                    ForEach(userCountGroup.historicalData, id: \.self) { userCount in
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
                NewUserCountGroupForm(isPresented: $isShowingCreateUserCountGroupView, app: app)
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
