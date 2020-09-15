//
//  UserCounterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI


struct UserCountView: View {
    let userCount: UserCount?
    let descriptionText: String
    let timeInterval: TimeInterval
    
    let numberFormatter = NumberFormatter()
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    
    var body: some View {
        CardView {
            VStack {
                if let count = userCount?.count, let countText = numberFormatter.string(from: NSNumber(value: count)) {
                    Text(countText).font(.system(size: 64, weight: .black, design: .monospaced))
                } else {
                    Text("–").font(.system(size: 64, weight: .black, design: .monospaced))
                }
                
                Text(descriptionText)
                
                let calculatedAt = userCount?.calculatedAt ?? Date()
                let calculationBeginDate = Date(timeInterval: timeInterval, since: calculatedAt)
                
                let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
                
                Text("In the last \(dateComponentsFormatter.string(from: dateComponents) ?? "—")")
            }
        }
    }
}

struct UserCountView_Previews: PreviewProvider {
    static var previews: some View {
        UserCountView(userCount: UserCount(count: 2401, calculatedAt: Date()), descriptionText: "Active Users", timeInterval: -3600*24)
    }
}
