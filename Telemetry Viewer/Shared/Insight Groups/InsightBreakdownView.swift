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
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        return numberFormatter
    }()
    
    let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
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
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading) {
                let dictionaryKeys = Array(insightData.data.keys).sorted()
                ForEach(dictionaryKeys, id: \.self) { key in
                    Text(key)
                    
                    if let insightData = insightData.data[key] {
                        Text("\(numberFormatter.string(from: NSNumber(value: insightData)) ?? "–")")
                            .font(.system(size: 17, weight: .black, design: .monospaced))
                            .frame(width: 80, alignment: .trailing)
                    } else {
                        Text("–")
                    }
                }
            }
            Spacer()
            
            HStack {
                Text(insightData.configuration["breakdown.payloadKey"] ?? "–")
                    .font(.system(.footnote, design: .monospaced))
                Text("\(relativeDateFormatter.localizedString(for: insightData.calculatedAt, relativeTo: Date()))")
            }
            .font(.footnote)
            .foregroundColor(grayColor)
        }
    }
}

struct InsightBreakdownView_Previews: PreviewProvider {
    static var platform: PreviewPlatform? = nil
    
    
    static var previews: some View {
        InsightBreakdownView(insightData: InsightDataTransferObject(
                                id: UUID(),
                                title: "System Version",
                                insightType: .breakdown,
                                timeInterval: -3600*24,
                                configuration: ["breakdown.payloadKey": "systemVersion"],
                                data: ["macOS 11.0.0": 1394, "iOS 14": 840, "iOS 13": 48],
                                calculatedAt: Date(timeIntervalSinceNow: -36)))
            .environmentObject(APIRepresentative())
            .previewLayout(.fixed(width: 300, height: 300))
    }
}
