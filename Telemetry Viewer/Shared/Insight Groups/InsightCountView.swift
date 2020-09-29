//
//  InsightCountView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 29.09.20.
//

import SwiftUI

struct InsightCountView: View {
    let insightData: InsightDataTransferObject
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    var body: some View {
        HStack {
            Spacer()
            if let count = insightData.data["count"], let countText = numberFormatter.string(from: NSNumber(value: count)) {
                Text(countText).font(.system(size: 64, weight: .black, design: .monospaced))
            } else {
                Text("–").font(.system(size: 64, weight: .black, design: .monospaced))
            }
        }
        .padding(.horizontal)
        
        
    }
}

struct InsightCountView_Previews: PreviewProvider {
    static var previews: some View {
        InsightCountView(insightData: InsightDataTransferObject(
                            id: UUID(),
                            title: "System Version",
                            insightType: .count,
                            timeInterval: -3600*24,
                            configuration: [:],
                            data: ["count": 1394],
                            calculatedAt: Date(timeIntervalSinceNow: -36)))
        .environmentObject(APIRepresentative())
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
