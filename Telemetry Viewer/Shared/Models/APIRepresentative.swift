//
//  APIRepresentative.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 05.09.20.
//

import Foundation

final class APIRepresentative: ObservableObject {
    @Published var user: OrganizationUser?
    @Published var userNotLoggedIn: Bool = true
    
    @Published var apps: [TelemetryApp] = [MockData.app1, MockData.app2]
    
    @Published var signals: [TelemetryApp: [Signal]] = MockData.signalsMockData
    @Published var userCounts: [TelemetryApp: [UserCountGroup]] = MockData.userCounts
    
    @Published var statistics: [TelemetryApp: [DerivedStatisticGroup]] = MockData.statistics
}
