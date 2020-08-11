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

var organization: Organization = .init(name: "breakthesystem")
var app1: TelemetryApp = .init(name: "Test App", organization: organization)
var app2: TelemetryApp = .init(name: "Other Test App", organization: organization)


final class SignalStore: ObservableObject {
    @Published var organzation: Organization = organization
    
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
}
