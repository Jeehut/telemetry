//
//  Models.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 09.08.20.
//

import Foundation

struct Organization: Codable, Hashable {
    var id: UUID?
    var name: String
}

struct TelemetryApp: Codable, Hashable {
    var id: UUID?
    var name: String
    var organization: Organization
}

struct Signal: Codable, Hashable {
    var id: UUID?
    var app: TelemetryApp
    var receivedAt: Date
    var clientUser: String
    var type: String
    var payload: Dictionary<String, String>?
}

struct UserCount: Codable, Hashable {
    let count: Int
    let calculatedAt: Date
}

struct UserCountGroup: Codable, Hashable {
    let title: String
    let timeInterval: TimeInterval
    let data: [UserCount]
}

var exampleOrganization: Organization = .init(name: "breakthesystem")
var app1: TelemetryApp = .init(name: "Test App", organization: exampleOrganization)
var app2: TelemetryApp = .init(name: "Other Test App", organization: exampleOrganization)



final class APIRepresentative: ObservableObject {
    @Published var organzation: Organization = exampleOrganization
    
    @Published var allApps: [TelemetryApp] = [app1, app2]
    
    @Published var allSignals: [TelemetryApp: [Signal]] = [
        app1: [
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app1, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
        ],
        app2: [
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
            .init(id: nil, app: app2, receivedAt: Date(), clientUser: "winsmith", type: "testSignal", payload: nil),
        ]
    ]
    
    @Published var userCounts: [TelemetryApp: [UserCountGroup]] = [
        app1: [
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
            
            UserCountGroup(title: "Active Users, 30 Days", timeInterval: -3600*24*30, data: [
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
            
            UserCountGroup(title: "Active Users, 30 Days", timeInterval: -3600*24*30, data: [
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
}
