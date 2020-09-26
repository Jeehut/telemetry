//
//  DerivedStatisticView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct DerivedStatisticView: View {
    @EnvironmentObject var api: APIRepresentative
    let derivedStatisticGroup: DerivedStatisticGroup
    let derivedStatistic: DerivedStatistic
    let app: TelemetryApp
    
    @State var rollingCurrentStatistics: [String: Int] = [:]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.fixed(80)),
    ]
    
    var body: some View {
        CardView {
            VStack(alignment: .leading) {
                Text(derivedStatistic.title).font(.title3)
                LazyVGrid(columns: columns, alignment: .leading) {
                    let dictionaryKeys = Array(rollingCurrentStatistics.keys).sorted()
                    ForEach(dictionaryKeys, id: \.self) { key in
                        Text(key)
                        Text("\(rollingCurrentStatistics[key] ?? 0)")
                            .font(.system(size: 17, weight: .black, design: .monospaced))
                            .frame(width: 80, alignment: .trailing)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            api.getAdditionalData(for: derivedStatistic, in: derivedStatisticGroup, in: app) { dto in
                self.rollingCurrentStatistics = dto
            }
        }
        
    }
}
//
//struct DerivedStatisticView_Previews: PreviewProvider {
//    static var previews: some View {
//        DerivedStatisticView(derivedStatistic: DerivedStatisticDataTransferObject(id: UUID(), title: "Libido Description Type", payloadKey: "omsn", rollingCurrentStatistics: ["colorful": 191, "neutral": 8, "unknown": 12], historicalData: []))
//    }
//}
