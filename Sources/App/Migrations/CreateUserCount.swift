//
//  File.swift
//  
//
//  Created by Daniel Jilg on 13.09.20.
//

import Fluent

extension UserCount {
    struct Migration: Fluent.Migration {
        var name: String { "CreateUserCount" }
        var schema = UserCount.schema
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema)
                .id()
                .field("count", .int, .required)
                .field("calculated_at", .datetime, .required)
                .field("usercount_group_id", .uuid, .required, .references(UserCountGroup.schema, "id"))
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(schema).delete()
        }
    }
}
