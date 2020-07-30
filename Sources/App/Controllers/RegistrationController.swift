import Fluent
import Vapor

struct RegistrationContoller: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post(use: create)
    }
    
    struct RegistrationRequestBody: Content, Validatable {
        let organisationName: String
        let userFirstName: String
        let userLastName: String
        let userEmail: String
        let userPassword: String
        let userPasswordConfirm: String
        
        func makeOrganisation() -> Organization {
            return Organization(name: organisationName)
        }
        
        func makeUser(organizationID: UUID) -> User {
            // TODO: Salt that hash, mofo!
            let hashedPassword = try! Bcrypt.hash(self.userPassword)
            
            return User(
                firstName: userFirstName,
                lastName: userLastName,
                email: userEmail,
                passwordHash: hashedPassword,
                organizationID: organizationID
            )
        }
        
        static func validations(_ validations: inout Validations) {
            validations.add("userFirstName", as: String.self, is: !.empty)
            validations.add("userLastName", as: String.self, is: !.empty)
            validations.add("userEmail", as: String.self, is: .email)
            validations.add("userPassword", as: String.self, is: .count(8...))
        }
    }
    
    func create(req: Request) throws -> EventLoopFuture<User> {
        try RegistrationRequestBody.validate(req)
        let registrationRequestBody = try req.content.decode(RegistrationRequestBody.self)
        
        guard registrationRequestBody.userPassword == registrationRequestBody.userPasswordConfirm else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let org = registrationRequestBody.makeOrganisation()
        
        return org.create(on: req.db).flatMap {
            let user = registrationRequestBody.makeUser(organizationID: org.id!)
            return user.create(on: req.db).map { user }
        }
    }
}
