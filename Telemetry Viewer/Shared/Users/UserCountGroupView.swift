//
//  UserCountListView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 31.08.20.
//

import SwiftUI

struct UserCountGroupView: View {
    let userCountGroups: [UserCountGroup]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(userCountGroups, id: \.self) { userCountGroup in
                    UserCountView(userCount: userCountGroup.data.first!, descriptionText: userCountGroup.title, timeInterval: userCountGroup.timeInterval)
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
