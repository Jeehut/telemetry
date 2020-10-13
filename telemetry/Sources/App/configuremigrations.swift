//
//  File.swift
//  
//
//  Created by Daniel Jilg on 13.10.20.
//

import Vapor
import Fluent

struct MigrationConfiguration {
    static func configureMigrations(_ app: Application) throws {
        app.migrations.add(Organization.Migration())
        app.migrations.add(App.Migration())
        app.migrations.add(Signal.Migration())
        app.migrations.add(Signal.UpdateReceivedAt())

        app.migrations.add(User.Migration())
        app.migrations.add(UserToken.Migration())
        
        app.migrations.add(InsightGroup.Migration())
        app.migrations.add(Insight.Migration())
        app.migrations.add(InsightHistoricalData.Migration())
        app.migrations.add(InsightHistoricalData.Migration2())
        app.migrations.add(Insight.Migration2())
        app.migrations.add(InsightGroup.AddOrderField())
        
        app.migrations.add(RegistrationToken.CreationMigration())

        try app.autoMigrate().wait()
    }
}
