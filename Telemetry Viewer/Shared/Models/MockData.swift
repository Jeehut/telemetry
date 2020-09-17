//
//  MockData.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

struct MockData {
    static let exampleOrganization: Organization = .init(name: "breakthesystem")
    
    static let app1: TelemetryApp = .init(name: "Test App", organization: ["id":"123"], isMockData: true)
    static let app2: TelemetryApp = .init(name: "Other Test App", organization: ["id":"123"], isMockData: true)
    
    static let examplePayload: [String: String] = [
        "isTestFlight": "true",
    ]
    
    static let signals: [Signal] = [
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        .init(id: nil, receivedAt: "Date()", clientUser: "winsmith", type: "testSignal", payload: examplePayload),
    ]
    
    static let userCounts:  [UserCountGroup] = [
        UserCountGroup(id: UUID(), app: nil, title: "Active Users", timeInterval: -3600*24, historicalData: [
            UserCount(id: nil, count: 46, calculatedAt: Date()),
            UserCount(id: nil, count: 41, calculatedAt: Date(timeInterval: -3600*24, since: Date())),
            UserCount(id: nil, count: 63, calculatedAt: Date(timeInterval: -3600*24*2, since: Date())),
            UserCount(id: nil, count: 63, calculatedAt: Date(timeInterval: -3600*24*3, since: Date())),
            UserCount(id: nil, count: 58, calculatedAt: Date(timeInterval: -3600*24*4, since: Date())),
            UserCount(id: nil, count: 57, calculatedAt: Date(timeInterval: -3600*24*5, since: Date())),
            UserCount(id: nil, count: 49, calculatedAt: Date(timeInterval: -3600*24*6, since: Date())),
            UserCount(id: nil, count: 55, calculatedAt: Date(timeInterval: -3600*24*7, since: Date())),
            UserCount(id: nil, count: 47, calculatedAt: Date(timeInterval: -3600*24*8, since: Date())),
            UserCount(id: nil, count: 39, calculatedAt: Date(timeInterval: -3600*24*9, since: Date())),
            UserCount(id: nil, count: 45, calculatedAt: Date(timeInterval: -3600*24*10, since: Date())),
        ], rollingCurrentCount: 121),
            
        UserCountGroup(id: UUID(), app: nil, title: "Active Users", timeInterval: -3600*24*7, historicalData: [
            UserCount(id: nil, count: 246, calculatedAt: Date()),
            UserCount(id: nil, count: 241, calculatedAt: Date(timeInterval: -3600*24, since: Date())),
            UserCount(id: nil, count: 263, calculatedAt: Date(timeInterval: -3600*24*2, since: Date())),
            UserCount(id: nil, count: 263, calculatedAt: Date(timeInterval: -3600*24*3, since: Date())),
            UserCount(id: nil, count: 258, calculatedAt: Date(timeInterval: -3600*24*4, since: Date())),
            UserCount(id: nil, count: 257, calculatedAt: Date(timeInterval: -3600*24*5, since: Date())),
            UserCount(id: nil, count: 249, calculatedAt: Date(timeInterval: -3600*24*6, since: Date())),
            UserCount(id: nil, count: 255, calculatedAt: Date(timeInterval: -3600*24*7, since: Date())),
            UserCount(id: nil, count: 247, calculatedAt: Date(timeInterval: -3600*24*8, since: Date())),
            UserCount(id: nil, count: 239, calculatedAt: Date(timeInterval: -3600*24*9, since: Date())),
            UserCount(id: nil, count: 245, calculatedAt: Date(timeInterval: -3600*24*10, since: Date())),
        ], rollingCurrentCount: 123),
            
        UserCountGroup(id: UUID(), app: nil, title: "Active Users", timeInterval: -3600*24*30, historicalData: [
            UserCount(id: nil, count: 446, calculatedAt: Date()),
            UserCount(id: nil, count: 241, calculatedAt: Date(timeInterval: -3600*24, since: Date())),
            UserCount(id: nil, count: 263, calculatedAt: Date(timeInterval: -3600*24*2, since: Date())),
            UserCount(id: nil, count: 263, calculatedAt: Date(timeInterval: -3600*24*3, since: Date())),
            UserCount(id: nil, count: 258, calculatedAt: Date(timeInterval: -3600*24*4, since: Date())),
            UserCount(id: nil, count: 257, calculatedAt: Date(timeInterval: -3600*24*5, since: Date())),
            UserCount(id: nil, count: 249, calculatedAt: Date(timeInterval: -3600*24*6, since: Date())),
            UserCount(id: nil, count: 255, calculatedAt: Date(timeInterval: -3600*24*7, since: Date())),
            UserCount(id: nil, count: 247, calculatedAt: Date(timeInterval: -3600*24*8, since: Date())),
            UserCount(id: nil, count: 239, calculatedAt: Date(timeInterval: -3600*24*9, since: Date())),
            UserCount(id: nil, count: 245, calculatedAt: Date(timeInterval: -3600*24*10, since: Date())),
        ], rollingCurrentCount: 125),
    ]
    
    static let derivedStatisticGroups: [DerivedStatisticGroup] = [
        DerivedStatisticGroup(title: "System Information", derivedStatistics: [
            DerivedStatistic(title: "App Version", rollingCurrentStatistics: ["8": 233, "4": 1], historicalData: []),
            DerivedStatistic(title: "System Version", rollingCurrentStatistics: ["13.6": 83, "13.5.1": 81, "13.3.1": 1, "None": 1, "13.6.1": 28, "14.0": 21], historicalData: [])
        ]),
        DerivedStatisticGroup(title: "Usage", derivedStatistics: [
            DerivedStatistic(title: "Libido Description Type", rollingCurrentStatistics: ["Colorful": 197, "Neutral": 26, "None": 1], historicalData: []),
            DerivedStatistic(title: "Should Send Notifications", rollingCurrentStatistics: ["False": 138, "True": 85], historicalData: []),
            DerivedStatistic(title: "Will Send Notifications", rollingCurrentStatistics: ["False": 138, "True": 85], historicalData: []),
            DerivedStatistic(title: "Cool Mode", rollingCurrentStatistics: ["Off": 38, "On": 185], historicalData: []),
        ]),
    ]
}





