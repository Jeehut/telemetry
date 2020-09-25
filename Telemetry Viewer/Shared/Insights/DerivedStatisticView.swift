//
//  DerivedStatisticView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct DerivedStatisticView: View {
    let derivedStatistic: DerivedStatistic
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.fixed(80)),
    ]
    
    var body: some View {
        CardView {
            VStack(alignment: .leading) {
                Text(derivedStatistic.title).font(.title3)
                LazyVGrid(columns: columns, alignment: .leading) {
                    let dictionaryKeys = Array(derivedStatistic.rollingCurrentStatistics.keys).sorted()
                    ForEach(dictionaryKeys, id: \.self) { key in
                        Text(key)
                        Text("\(derivedStatistic.rollingCurrentStatistics[key] ?? 0)")
                            .font(.system(size: 17, weight: .black, design: .monospaced))
                            .frame(width: 80, alignment: .trailing)
                    }
                }
                Spacer()
            }
        }
    }
}

struct DerivedStatisticView_Previews: PreviewProvider {
    static var previews: some View {
        DerivedStatisticView(derivedStatistic: DerivedStatistic(id: UUID(), title: "Libido Description Type", payloadKey: "omsn", rollingCurrentStatistics: ["colorful": 191, "neutral": 8, "unknown": 12], historicalData: []))
    }
}
