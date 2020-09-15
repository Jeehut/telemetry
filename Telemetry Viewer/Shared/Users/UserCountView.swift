//
//  UserCounterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI


struct UserCountView: View {
    let userCountGroup: UserCountGroup
    
    let numberFormatter = NumberFormatter()
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    
    var body: some View {
        CardView {
            VStack {
                if let count = userCountGroup.rollingCurrentCount, let countText = numberFormatter.string(from: NSNumber(value: count)) {
                    Text(countText).font(.system(size: 64, weight: .black, design: .monospaced))
                } else {
                    Text("–").font(.system(size: 64, weight: .black, design: .monospaced))
                }
                
                Text(userCountGroup.title)
                
                let calculatedAt = Date()
                let calculationBeginDate = Date(timeInterval: userCountGroup.timeInterval, since: calculatedAt)
                
                let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
                
                Text("In the last \(dateComponentsFormatter.string(from: dateComponents) ?? "—")")
            }
        }
    }
}
