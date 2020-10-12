//
//  File.swift
//  
//
//  Created by Daniel Jilg on 12.10.20.
//

import Fluent

extension RegistrationToken {
    struct CreationMigration: Fluent.Migration {
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(RegistrationToken.schema)
                .id()
                .field("value", .string, .required)
                .field("is_used", .bool, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(RegistrationToken.schema).delete()
        }
    }
}
