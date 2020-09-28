//
//  InsightBreakdownView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct InsightBreakdownView: View {
    @EnvironmentObject var api: APIRepresentative
    let insightData: InsightDataTransferObject
    
    var body: some View {
        Text("Hello, \(insightData.title)")
    }
}

struct InsightBreakdownView_Previews: PreviewProvider {
    static var platform: PreviewPlatform? = nil

    
    static var previews: some View {
        InsightBreakdownView(insightData: InsightDataTransferObject(
                                id: UUID(),
                                title: "System Version",
                                insightType: .breakdown,
                                configuration: ["breakdown.payloadKeyword": "systemVersion"],
                                data: ["macOS 11": 1394, "iOS 14": 840, "iOS 13": 48]))
            .environmentObject(APIRepresentative())
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
