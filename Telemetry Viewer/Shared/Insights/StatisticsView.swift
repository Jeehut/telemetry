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
    
    @State var isShowingNewDerivedStatisticGroupView = false
    @State var isShowingNewDerivedStatisticView = false
    
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
                            
                            CardView {
                                Button(action: {
                                    isShowingNewDerivedStatisticView = true
                                }) {
                                    Label("New Derived Statistic", systemImage: "rectangle.badge.plus")
                                }
                                .sheet(isPresented: $isShowingNewDerivedStatisticView) {
                                    // TODO: The derivedStatisticGroup is always the first one here
                                    NewDerivedStatisticView(isPresented: $isShowingNewDerivedStatisticView, app: app, derivedStatisticGroup: statisticsGroup)
                                }
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
            api.getDerivedStatisticGroups(for: app)
            TelemetryManager().send(.telemetryAppInsightsShown, for: api.user?.email ?? "unregistered user")
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    isShowingNewDerivedStatisticGroupView = true
                }) {
                    Label("New Derived Statistic Group", systemImage: "rectangle.badge.plus")
                }
                .sheet(isPresented: $isShowingNewDerivedStatisticGroupView) {
                        NewDerivedStatisticGroupView(isPresented: $isShowingNewDerivedStatisticGroupView, app: app)
                }
                
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(app: MockData.app1)
    }
}
