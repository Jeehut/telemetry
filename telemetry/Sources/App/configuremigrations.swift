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
        app.migrations.add(OldInsight.Migration())
        app.migrations.add(OldInsightHistoricalData.Migration())
        app.migrations.add(OldInsightHistoricalData.Migration2())
        app.migrations.add(OldInsight.Migration2())
        app.migrations.add(InsightGroup.AddOrderField())
        
        app.migrations.add(RegistrationToken.CreationMigration())
        
        app.migrations.add(Insight.CreationMigration())

        try app.autoMigrate().wait()
    }
}
