//
//  InsightGroupList.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 28.09.20.
//

import SwiftUI

struct InsightGroupList: View {
    @EnvironmentObject var api: APIRepresentative
    var app: TelemetryApp
    
    @State var isShowingNewDerivedStatisticGroupView = false
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], alignment: .leading) {
                if let insightGroups = api.insightGroups[app] {
                    ForEach(insightGroups, id: \.id) { insightGroup in
                        Section(header: HStack {
                            Text(insightGroup.title).font(.title)
                            Button(
                                action: { api.delete(insightGroup: insightGroup, in: app) },
                                label: { Image(systemName: "xmark.circle.fill") })
                            
                        }) {
                            ForEach(insightGroup.insights, id: \.id) { insight in
                                ZStack(alignment: Alignment.topTrailing) {
                                    CardView {
                                        Text(insight.title)
                                    }
                                    
                                    Button(
                                        action: {
//                                            api.delete(derivedStatistic: derivedStatistic, in: statisticsGroup, in: app)
                                            
                                        },
                                        label: {
                                            Image(systemName: "xmark.circle.fill")
                                        })
                                        .offset(x: -10, y: 10)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            api.getInsightGroups(for: app)
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
                        NewInsightGroupView(isPresented: $isShowingNewDerivedStatisticGroupView, app: app)
                }
                
            }
        }
    }
}

struct InsightGroupList_Previews: PreviewProvider {
    static var previews: some View {
        InsightGroupList(app: MockData.app1)
    }
}
