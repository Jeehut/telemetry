import Fluent
import Vapor

struct RegistrationContoller: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post(use: create)
    }
    
    struct RegistrationRequestBody: Content {
        let organisationName: String
        let userFirstName: String
        let userLastName: String
        let userEmail: String
        let userPassword: String
        let userPasswordConfirm: String
        
        func makeOrganisation() -> Organization {
            return Organization(name: organisationName)
        }
        
        func makeUser() -> User {
            // TODO: This is bonkers and wrong
            return User(name: userFirstName, email: userEmail, passwordHash: userPassword)
        }
    }
    
    func create(req: Request) throws -> EventLoopFuture<Organization> {
        let registrationRequestBody = try req.content.decode(RegistrationRequestBody.self)
        let org = registrationRequestBody.makeOrganisation()
        let user = registrationRequestBody.makeUser()
        
        return org.save(on: req.db).map { org }
        
    }
}
