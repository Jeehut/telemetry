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
    
    let columns = [
        GridItem(.adaptive(minimum: 200))
    ]
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, alignment: .leading) {
                
                if let statisticsGroups = api.derivedStatisticGroups[app] {
                    ForEach(statisticsGroups, id: \.self) { statisticsGroup in
                        Section(header: Text(statisticsGroup.title).font(.title)) {
                            ForEach(statisticsGroup.derivedStatistics, id: \.self) { derivedStatistic in
                                DerivedStatisticView(derivedStatistic: derivedStatistic)
                            }
                        }
                    }
                } else {
                    
                    ForEach(MockData.derivedStatisticGroups, id: \.self) { statisticsGroup in
                        Section(header: Text(statisticsGroup.title).font(.title)) {
                            ForEach(statisticsGroup.derivedStatistics, id: \.self) { derivedStatistic in
                                DerivedStatisticView(derivedStatistic: derivedStatistic)
                            }
                        }.redacted(reason: .placeholder)
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
