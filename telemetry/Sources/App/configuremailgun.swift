//
//  File.swift
//  
//
//  Created by Daniel Jilg on 07.12.20.
//

import Vapor
import Mailgun

extension MailgunDomain {
    static var mailDotApptelemetryDotIo: MailgunDomain { .init("mail.apptelemetry.io", .eu) }
}

struct CustomEmailConfiguration {
    static func configureEmaik(_ app: Application) throws {
        app.mailgun.configuration = .init(apiKey: "<api key>")
        app.mailgun.defaultDomain = .mailDotApptelemetryDotIo
    }
}
