//
//  StatisticsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct StatisticsView: View {
    let statisticsGroups: [DerivedStatisticGroup]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(statisticsGroups, id: \.self) { statisticsGroup in
                    Section(header: Text(statisticsGroup.title).font(.title)) {
                        ForEach(statisticsGroup.derivedStatistics, id: \.self) { derivedStatistic in
                            DerivedStatisticView(derivedStatistic: derivedStatistic)
                        }
                    }
                    
                    
                }
            }
            .padding()
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(statisticsGroups: APIRepresentative().statistics[app1]!)
    }
}
