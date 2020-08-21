//
//  UserCounterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI

struct UserCount {
    let count: Int
    let timeFrom: Date
    let timeUntil: Date
    let filterText: String
}

struct UserCounterView: View {
    let userCount: UserCount
    let numberFormatter = NumberFormatter()
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text(numberFormatter.string(from: NSNumber(value: userCount.count)) ?? "–").font(.system(size: 64, weight: .black, design: .monospaced))
            Text(userCount.filterText)
            
            let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: userCount.timeFrom, to: userCount.timeUntil)
            Text("In the last \(dateComponentsFormatter.string(from: dateComponents) ?? "—")")
        }
        .padding()
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue, lineWidth: 4)
            )
        
    }
}

struct UserCounterView_Previews: PreviewProvider {
    static var platform: PreviewPlatform? { return nil }
    
    static var previews: some View {
        let userCount: UserCount = UserCount(count: 1918, timeFrom: Date(timeInterval: -3600*13, since: Date()), timeUntil: Date(), filterText: "Active Users")
        
        UserCounterView(userCount: userCount)
    }
}
