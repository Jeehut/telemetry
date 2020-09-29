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
    
    let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    var body: some View {
        
        #if os (macOS)
        let grayColor = Color(NSColor.systemGray)
        #else
        let grayColor = Color(UIColor.systemGray)
        #endif
        
        VStack(alignment: .leading) {
            Text(insight.title).font(.title3)
            
            
            
            let calculatedAt = Date()
            let calculationBeginDate = Date(timeInterval: insight.timeInterval, since: calculatedAt)
            
            let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.day, .hour, .minute], from: calculationBeginDate, to: calculatedAt)
            Text("\(insight.insightType.humanReadableName) of signals less than \(dateComponentsFormatter.string(from: dateComponents) ?? "—") old")
                .font(.footnote)
                .foregroundColor(grayColor)
            
            if insightData == nil {
                
                Text("Oh yes we are still Loading and it is taking some time but oh well look at these nice redacted things")
                    .redacted(reason: .placeholder)
                    .onAppear {
                        api.getInsightData(for: insight, in: insightGroup, in: app) { insightData in
                            self.insightData = insightData
                        }
                    }
                
                Text("This data was calculated by elves")
                    .redacted(reason: .placeholder)
                    .font(.footnote)
                    .foregroundColor(grayColor)
            }
            
            else {
                switch insightData!.insightType {
                case .breakdown:
                    InsightBreakdownView(insightData: insightData!)
                default:
                    VStack(alignment: .leading) {
                        Text(insight.title).font(.title3)
                        Text("This Insight Type is not supported yet")
                    }
                    
                }
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
            insight: Insight(id: UUID(), title: "System Version", insightType: .breakdown, timeInterval: -3600*24, configuration: ["breakdown.payloadKey": "systemVersion"], historicalData: [])
        )
        .padding()
        .environmentObject(APIRepresentative())
        .previewLayout(.fixed(width: 400, height: 200))
    }
}
