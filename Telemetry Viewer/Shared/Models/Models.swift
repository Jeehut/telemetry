//
//  Models.swift
//  Telemetry Viewer
//
//  Created by Daniel Jilg on 09.08.20.
//

import Foundation

struct OrganizationUser: Codable, Hashable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var organization: Organization
    var passwordHash: String
}

struct Organization: Codable, Hashable {
    var id: UUID?
    var name: String
}

struct TelemetryApp: Codable, Hashable {
    var id: UUID?
    var name: String
    var organization: [String: String]
    var isMockData: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, name, organization
    }
}

struct Signal: Codable, Hashable {
    var id: UUID?
    var receivedAt: String// Date
    var clientUser: String
    var type: String
    var payload: Dictionary<String, String>?
}

struct UserCount: Codable, Hashable {
    let count: Int
    let calculatedAt: Date
}

struct UserCountGroup: Codable, Hashable, Identifiable {
    let id: UUID
    let app: [String: String]?
    let title: String
    let timeInterval: TimeInterval
    let data: [UserCount]
}

struct DerivedStatisticGroup: Codable, Hashable {
    let title: String
    let derivedStatistics: [DerivedStatistic]
    var isMockData: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case title, derivedStatistics
    }
}

struct DerivedStatistic: Codable, Hashable {
    let title: String
    let statistics: [String: Int]
}
