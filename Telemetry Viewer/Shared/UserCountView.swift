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
        VStack {
            Text(numberFormatter.string(from: NSNumber(value: userCount.count)) ?? "–").font(.system(size: 64, weight: .black, design: .monospaced))
            Text(descriptionText)
            
            let calculatedAt = userCount.calculatedAt
            let calculationBeginDate = Date(timeInterval: timeInterval, since: calculatedAt)
            Text("In the last \(dateIntervalFormatter.string(from: calculationBeginDate, to: calculatedAt))")
        }
        .padding()
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue, lineWidth: 4)
            )
        
    }
}
