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
    let timeFrom: Date
    let timeUntil: Date
    let filterText: String
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
    
    @Published var userCounts: [TelemetryApp: [UserCount]] = [
        app1: [
            UserCount(count: 46, timeFrom: Date(timeInterval: -3600*24, since: Date()), timeUntil: Date(), filterText: "Active Users"),
            UserCount(count: 93, timeFrom: Date(timeInterval: -3600*24*7, since: Date()), timeUntil: Date(), filterText: "Active Users"),
            UserCount(count: 225, timeFrom: Date(timeInterval: -3600*24*30, since: Date()), timeUntil: Date(), filterText: "Active Users"),
            UserCount(count: 108, timeFrom: Date(timeInterval: -3600*24*30, since: Date()), timeUntil: Date(), filterText: "Long-Term Users")
        ],
        app2: [
            UserCount(count: 133, timeFrom: Date(timeInterval: -3600*24, since: Date()), timeUntil: Date(), filterText: "Active Users")
        ]
    ]
}
