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
    var id: UUID
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
    let id: UUID?
    let count: Int
    let calculatedAt: Date
}

struct UserCountGroup: Codable, Hashable, Identifiable {
    let id: UUID
    let app: [String: String]?
    let title: String
    let timeInterval: TimeInterval
    let historicalData: [UserCount]
    let rollingCurrentCount: Int
}

struct DerivedStatisticGroup: Codable, Hashable {
    let id: UUID
    let title: String
    let derivedStatistics: [DerivedStatistic]
}

struct DerivedStatistic: Codable, Hashable {
    var id: UUID
    let title: String
    let payloadKey: String
}

struct DerivedStatisticDataTransferObject: Codable, Hashable {
    var id: UUID
    let title: String
    let payloadKey: String
    let rollingCurrentStatistics: [String: Int]
    let historicalData: [DerivedStatisticHistoricalData]
}

struct DerivedStatisticHistoricalData: Codable, Hashable {
    var id: UUID
    let statistics: [String: Int]
    let calculatedAt: Date
}

struct UserCountGroupCreateRequestBody: Codable {
    var title: String
    var timeInterval: TimeInterval
}

struct DerivedStatisticCreateRequestBody: Codable {
    var title: String
    var payloadKey: String
}

struct InsightGroup: Codable {
    var id: UUID
    var title: String
    var insights: [Insight] = []
}

struct Insight: Codable {
    var id: UUID
    var title: String
    var configuration: [String: String]
    var historicalData: [InsightHistoricalData]?
}

struct InsightHistoricalData: Codable {
    var id: UUID
    var data: [String: Float]
}

enum InsightType: String, Codable {
    case breakdown
    case mean
}

struct InsightDataTransferObject: Codable {
    let id: UUID
    let title: String
    let insightType: InsightType
    let configuration: [String: String]
    let data: [String: Float]
}

struct InsightCreateRequestBody: Codable {
    var title: String
    var insightType: InsightType
    var configuration: [String: String]
}
