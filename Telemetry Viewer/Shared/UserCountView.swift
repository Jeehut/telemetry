//
//  UserCounterView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 11.08.20.
//

import SwiftUI


struct UserCountView: View {
    let userCount: UserCount
    let descriptionText: String
    let timeInterval: TimeInterval
    
    let numberFormatter = NumberFormatter()
    let dateIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.white)
                .shadow(radius: 7, x: 0, y: 5)
            
            VStack {
                Text(numberFormatter.string(from: NSNumber(value: userCount.count)) ?? "–").font(.system(size: 64, weight: .black, design: .monospaced))
                Text(descriptionText)
                
                let calculatedAt = userCount.calculatedAt
                let calculationBeginDate = Date(timeInterval: timeInterval, since: calculatedAt)
                Text("In the last \(dateIntervalFormatter.string(from: calculationBeginDate, to: calculatedAt))")
            }
            .padding()
        }
        .padding()
        
        
        
        
        
        
    }
}

struct UserCountView_Previews: PreviewProvider {
    static var previews: some View {
        UserCountView(userCount: UserCount(count: 2401, calculatedAt: Date()), descriptionText: "Active Users", timeInterval: -3600*24)
    }
}
