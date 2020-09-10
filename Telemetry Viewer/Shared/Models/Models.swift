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

struct PayloadEntry: Codable, Hashable {
    let boolValue: Bool?
    let intValue: Int?
    let floatValue: Float?
    let stringValue: String?
    let listValue: [PayloadEntry]?
    let dictValue: [String: PayloadEntry]?
    
    static func p(_ bool: Bool) -> PayloadEntry {
        return PayloadEntry(boolValue: bool, intValue: nil, floatValue: nil, stringValue: nil, listValue: nil, dictValue: nil)
    }
    static func p(_ int: Int) -> PayloadEntry {
        return PayloadEntry(boolValue: nil, intValue: int, floatValue: nil, stringValue: nil, listValue: nil, dictValue: nil)
    }
    static func p(_ float: Float) -> PayloadEntry {
        return PayloadEntry(boolValue: nil, intValue: nil, floatValue: float, stringValue: nil, listValue: nil, dictValue: nil)
    }
    static func p(_ string: String) -> PayloadEntry {
        return PayloadEntry(boolValue: nil, intValue: nil, floatValue: nil, stringValue: nil, listValue: nil, dictValue: nil)
    }
    static func p(_ list: [PayloadEntry]) -> PayloadEntry {
        return PayloadEntry(boolValue: nil, intValue: nil, floatValue: nil, stringValue: nil, listValue: list, dictValue: nil)
    }
    static func p(_ dict: [String: PayloadEntry]) -> PayloadEntry {
        return PayloadEntry(boolValue: nil, intValue: nil, floatValue: nil, stringValue: nil, listValue: nil, dictValue: dict)
    }
}

struct Signal: Codable, Hashable {
    var id: UUID?
    var app: TelemetryApp
    var receivedAt: Date
    var clientUser: String
    var type: String
    var payload: Dictionary<String, PayloadEntry>?
}

struct UserCount: Codable, Hashable {
    let count: Int
    let calculatedAt: Date
}

struct UserCountGroup: Codable, Hashable {
    let title: String
    let timeInterval: TimeInterval
    let data: [UserCount]
    var isMockData: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case title, timeInterval, data
    }
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
