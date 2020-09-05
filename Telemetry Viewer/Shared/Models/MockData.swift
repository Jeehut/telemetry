//
//  MockData.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

struct MockData {
    static let exampleOrganization: Organization = .init(name: "breakthesystem")
    
    static let app1: TelemetryApp = .init(name: "Test App", organization: exampleOrganization)
    static let app2: TelemetryApp = .init(name: "Other Test App", organization: exampleOrganization)
    
    static let examplePayload: [String: PayloadEntry] = [
        "isTestFlight": .p(true),
        "numberOfLibidoDataPoints": .p(141),
        "isAppStore": .p(true),
        "numberOfEnergyLevelDataPoints": .p(141),
        "furthestOnboardingScreenSeen": .p(4),
        "numberOfCreateDialogs": .p(4),
        "numberOfMoodDataPoints": .p(143),
        "systemVersion": .p("14.0"),
        "libidoDescriptionType": .p("neutral"),
        "shouldSendExperienceSamplingNotifications": .p(true),
        "buildNumber": .p("278"),
        "chartRowTypesInOverview": .p([
            .p("libido"), .p("mood"), .p("energyLevel"), .p("sexualActivity"), .p("orgasms"),
        ])
    ]
    
    static let signalsMockData: [TelemetryApp: [Signal]] = [
        app1: [
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        ],
        app2: [
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: examplePayload),
        ]
    ]
    
    static let userCounts: [TelemetryApp: [UserCountGroup]] = [
        app1: [
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
            ]),
            
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
            ]),
            
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
            ]),
            
            UserCountGroup(title: "Long-Term Users", timeInterval: -3600*24*30, data: [
                UserCount(count: 197, calculatedAt: Date()),
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
            ])
        ],
        
        app2: [
            UserCountGroup(title: "Active Users, 24 Hours", timeInterval: -3600*24, data: [
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
            ]),
            
            UserCountGroup(title: "Active Users, 7 Days", timeInterval: -3600*24*7, data: [
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
            ]),
            
            UserCountGroup(title: "Active Users", timeInterval: -3600*24*30, data: [
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
            ]),
            
            UserCountGroup(title: "Long-Term Users, 30 Days", timeInterval: -3600*24*30, data: [
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
            ])
        ],
    ]
    
    static let statistics: [TelemetryApp: [DerivedStatisticGroup]] = [
        app1: [
            DerivedStatisticGroup(title: "System Information", derivedStatistics: [
                DerivedStatistic(title: "App Version", statistics: ["8": 233, "4": 1]),
                DerivedStatistic(title: "System Version", statistics: ["13.6": 83, "13.5.1": 81, "13.3.1": 1, "None": 1, "13.6.1": 28, "14.0": 21])
            ]),
            DerivedStatisticGroup(title: "Usage", derivedStatistics: [
                DerivedStatistic(title: "Libido Description Type", statistics: ["Colorful": 197, "Neutral": 26, "None": 1]),
                DerivedStatistic(title: "Should Send Notifications", statistics: ["False": 138, "True": 85]),
                DerivedStatistic(title: "Will Send Notifications", statistics: ["False": 138, "True": 85]),
                DerivedStatistic(title: "Cool Mode", statistics: ["Off": 38, "On": 185]),
            ]),
        ],
        
        app2: [
            DerivedStatisticGroup(title: "System Information", derivedStatistics: [
                DerivedStatistic(title: "App Version", statistics: ["8": 233, "4": 1]),
                DerivedStatistic(title: "System Version", statistics: ["13.6": 83, "13.5.1": 81, "13.3.1": 1, "None": 1, "13.6.1": 28, "14.0": 21])
            ]),
            DerivedStatisticGroup(title: "Usage", derivedStatistics: [
                DerivedStatistic(title: "Libido Description Type", statistics: ["Colorful": 197, "Neutral": 26, "None": 1]),
                DerivedStatistic(title: "Should Send Notifications", statistics: ["False": 138, "True": 85]),
            ])
        ]
    ]
}





