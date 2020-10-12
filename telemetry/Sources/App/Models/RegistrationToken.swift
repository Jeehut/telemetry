//
//  File.swift
//  
//
//  Created by Daniel Jilg on 12.10.20.
//

import Fluent
import Vapor

final class RegistrationToken: Model, Content {
    static let schema = "registration_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "is_used")
    var isUsed: Bool
}
