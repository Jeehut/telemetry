//
//  StatisticsView.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 02.09.20.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    
    var statisticsGroups: [DerivedStatisticGroup] {
        return api.derivedStatisticGroups[app, default: MockData.derivedStatisticGroups]
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, alignment: .leading) {
                ForEach(statisticsGroups, id: \.self) { statisticsGroup in
                    
                    if statisticsGroup.isMockData {
                        Section(header: Text(statisticsGroup.title).font(.title)) {
                            ForEach(statisticsGroup.derivedStatistics, id: \.self) { derivedStatistic in
                                DerivedStatisticView(derivedStatistic: derivedStatistic)
                            }
                        }.redacted(reason: .placeholder)
                    } else {
                    
                        Section(header: Text(statisticsGroup.title).font(.title)) {
                            ForEach(statisticsGroup.derivedStatistics, id: \.self) { derivedStatistic in
                                DerivedStatisticView(derivedStatistic: derivedStatistic)
                            }
                        }
                    }
                    
                    
                }
            }
            .padding()
        }
        .onAppear {
            TelemetryManager().send(.telemetryAppInsightsShown, for: api.user?.email ?? "unregistered user")
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(app: MockData.app1)
    }
}
