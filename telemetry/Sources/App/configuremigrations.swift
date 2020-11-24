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
        app.migrations.add(InsightGroup.AddOrderField())
        
        app.migrations.add(Insight.CreationMigration())
        app.migrations.add(Insight.DeleteOldTablesMigration())
        
        app.migrations.add(Insight.AddIsExpandedField())
        app.migrations.add(Organization.AddIsSuperOrgField())
        app.migrations.add(BetaRequestEmail.Migration())

        app.migrations.add(LexiconSignalType.Migration())
        app.migrations.add(LexiconPayloadKey.Migration())

        app.migrations.add(BetaRequestEmail.Migration2())
        app.migrations.add(User.Migration2())
        app.migrations.add(OrganizationJoinRequest.Migration())
        
        app.migrations.add(BetaRequestEmail.Migration3())
        app.migrations.add(Insight.Migration4())
        app.migrations.add(LexiconSignalType.Migration2())
        app.migrations.add(LexiconPayloadKey.Migration2())
        
        try app.autoMigrate().wait()
    }
}
