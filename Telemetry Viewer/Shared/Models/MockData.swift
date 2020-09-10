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
    
    static let examplePayload: [String: PayloadEntry] = [
        "isTestFlight": .p(true),
    ]
    
    static let signals: [Signal] = [
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload, isMockData: true),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload, isMockData: true),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload, isMockData: true),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload, isMockData: true),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload, isMockData: true),
        .init(id: nil, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload, isMockData: true),
    ]
    
    static let userCounts:  [UserCountGroup] = [
            UserCountGroup(title: "Active Users", timeInterval: -3600*24, data: [
                UserCount(count: 46, calculatedAt: Date()),
                UserCount(count: 41, calculatedAt: Date(timeInterval: -3600*24, since: Date())),
                UserCount(count: 63, calculatedAt: Date(timeInterval: -3600*24*2, since: Date())),
                UserCount(count: 63, calculatedAt: Date(timeInterval: -3600*24*3, since: Date())),
                UserCount(count: 58, calculatedAt: Date(timeInterval: -3600*24*4, since: Date())),
                UserCount(count: 57, calculatedAt: Date(timeInterval: -3600*24*5, since: Date())),
                UserCount(count: 49, calculatedAt: Date(timeInterval: -3600*24*6, since: Date())),
                UserCount(count: 55, calculatedAt: Date(timeInterval: -3600*24*7, since: Date())),
                UserCount(count: 47, calculatedAt: Date(timeInterval: -3600*24*8, since: Date())),
                UserCount(count: 39, calculatedAt: Date(timeInterval: -3600*24*9, since: Date())),
                UserCount(count: 45, calculatedAt: Date(timeInterval: -3600*24*10, since: Date())),
            ], isMockData: true),
            
            UserCountGroup(title: "Active Users", timeInterval: -3600*24*7, data: [
                UserCount(count: 246, calculatedAt: Date()),
                UserCount(count: 241, calculatedAt: Date(timeInterval: -3600*24, since: Date())),
                UserCount(count: 263, calculatedAt: Date(timeInterval: -3600*24*2, since: Date())),
                UserCount(count: 263, calculatedAt: Date(timeInterval: -3600*24*3, since: Date())),
                UserCount(count: 258, calculatedAt: Date(timeInterval: -3600*24*4, since: Date())),
                UserCount(count: 257, calculatedAt: Date(timeInterval: -3600*24*5, since: Date())),
                UserCount(count: 249, calculatedAt: Date(timeInterval: -3600*24*6, since: Date())),
                UserCount(count: 255, calculatedAt: Date(timeInterval: -3600*24*7, since: Date())),
                UserCount(count: 247, calculatedAt: Date(timeInterval: -3600*24*8, since: Date())),
                UserCount(count: 239, calculatedAt: Date(timeInterval: -3600*24*9, since: Date())),
                UserCount(count: 245, calculatedAt: Date(timeInterval: -3600*24*10, since: Date())),
            ], isMockData: true),
            
            UserCountGroup(title: "Active Users", timeInterval: -3600*24*30, data: [
                UserCount(count: 446, calculatedAt: Date()),
                UserCount(count: 241, calculatedAt: Date(timeInterval: -3600*24, since: Date())),
                UserCount(count: 263, calculatedAt: Date(timeInterval: -3600*24*2, since: Date())),
                UserCount(count: 263, calculatedAt: Date(timeInterval: -3600*24*3, since: Date())),
                UserCount(count: 258, calculatedAt: Date(timeInterval: -3600*24*4, since: Date())),
                UserCount(count: 257, calculatedAt: Date(timeInterval: -3600*24*5, since: Date())),
                UserCount(count: 249, calculatedAt: Date(timeInterval: -3600*24*6, since: Date())),
                UserCount(count: 255, calculatedAt: Date(timeInterval: -3600*24*7, since: Date())),
                UserCount(count: 247, calculatedAt: Date(timeInterval: -3600*24*8, since: Date())),
                UserCount(count: 239, calculatedAt: Date(timeInterval: -3600*24*9, since: Date())),
                UserCount(count: 245, calculatedAt: Date(timeInterval: -3600*24*10, since: Date())),
            ], isMockData: true),
    ]
    
    static let derivedStatisticGroups: [DerivedStatisticGroup] = [
        DerivedStatisticGroup(title: "System Information", derivedStatistics: [
            DerivedStatistic(title: "App Version", statistics: ["8": 233, "4": 1]),
            DerivedStatistic(title: "System Version", statistics: ["13.6": 83, "13.5.1": 81, "13.3.1": 1, "None": 1, "13.6.1": 28, "14.0": 21])
        ], isMockData: true),
        DerivedStatisticGroup(title: "Usage", derivedStatistics: [
            DerivedStatistic(title: "Libido Description Type", statistics: ["Colorful": 197, "Neutral": 26, "None": 1]),
            DerivedStatistic(title: "Should Send Notifications", statistics: ["False": 138, "True": 85]),
            DerivedStatistic(title: "Will Send Notifications", statistics: ["False": 138, "True": 85]),
            DerivedStatistic(title: "Cool Mode", statistics: ["Off": 38, "On": 185]),
        ], isMockData: true),
    ]
}





