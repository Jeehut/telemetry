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
    
    var userCountGroups: [UserCountGroup] {
        return api.userCounts[app, default: MockData.userCounts]
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 250))
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(userCountGroups, id: \.self) { userCountGroup in
                    if userCountGroup.isMockData {
                        UserCountView(userCount: userCountGroup.data.first!, descriptionText: userCountGroup.title, timeInterval: userCountGroup.timeInterval).redacted(reason: .placeholder)
                    } else {
                        UserCountView(userCount: userCountGroup.data.first!, descriptionText: userCountGroup.title, timeInterval: userCountGroup.timeInterval)
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
    }
}
