//
//  File.swift
//  
//
//  Created by Daniel Jilg on 13.10.20.
//

import Fluent
import Vapor
import FluentPostgresDriver
import FluentSQLiteDriver

struct CustomDatabaseConfiguration {
    static func configureDatabase(_ app: Application) throws {
        // app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
        try app.databases.use(.postgres(url: "postgresql://breakthesystem@localhost:5432/breakthesystem"), as: .psql)
    }
}
