//
//  InsightView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct InsightView: View {
    
    @EnvironmentObject var api: APIRepresentative
    let app: TelemetryApp
    let insightGroup: InsightGroup
    let insight: Insight
    
    @State var insightData: InsightDataTransferObject?
    
    var body: some View {
        if insightData == nil {
            Text("Loading")
                .onAppear {
                    api.getInsightData(for: insight, in: insightGroup, in: app) { insightData in
                        self.insightData = insightData
                    }
                }
        }
        
        else {
            switch insightData!.insightType {
            case .breakdown:
                InsightBreakdownView(insightData: insightData!)
            default:
                Text("This Insight Type is not supported yet")
            }
        }
        
    }
}

struct InsightView_Previews: PreviewProvider {
    static var platform: PreviewPlatform? = nil
    
    static var previews: some View {
        InsightView(
            app: MockData.app1,
            insightGroup: InsightGroup(id: UUID(), title: "Test Insight Group"),
            insight: Insight(id: UUID(), title: "System Version", configuration: ["breakdown.payloadKeyword": "systemVersion"], historicalData: [])
        )
        .environmentObject(APIRepresentative())
        .previewLayout(.fixed(width: 200, height: 200))
    }
}
