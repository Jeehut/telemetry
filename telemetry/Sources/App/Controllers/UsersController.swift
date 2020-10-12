import Fluent
import Vapor

struct UsersController: RouteCollection {
    enum RegistrationStatus: String {
        case registrationClosed
        case registrationViaToken
        case registrationOpen
    }
    
    let currentRegistrationStatus: RegistrationStatus = .registrationOpen
    
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("registrationStatus", use: getRegistrationStatus)
        routes.post("register", use: create)
        
        let passwordProtected = routes.grouped(User.authenticator())
        passwordProtected.post("login", use: getBearerTokenForUser)
        passwordProtected.post("createRegistrationToken", use: createRegistrationToken)
        
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: getUserInformation)
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
    
    func getRegistrationStatus(req: Request) throws -> [String: String] {
        return ["registrationStatus": self.currentRegistrationStatus.rawValue]
    }
    
    func createRegistrationToken(req: Request) throws -> EventLoopFuture<RegistrationToken> {
        try req.auth.require(User.self)
        
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let newTokenValue = String((0..<8).map{ _ in letters.randomElement()! })
        
        let token = RegistrationToken()
        token.value = newTokenValue
        token.isUsed = false
        
        return token.save(on: req.db)
            .map { token }
    }
    
    
    /// Register and Create a new Organization
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
    
    func getBearerTokenForUser(req: Request) throws -> EventLoopFuture<UserToken> {
            let user = try req.auth.require(User.self)
            let token = try user.generateToken()
            return token.save(on: req.db)
                .map { token }
    }
    
    func getUserInformation(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.auth.require(User.self)
        return user.$organization.load(on: req.db).map { user }
        // TODO: Do not return PasswordHash 
    }
}
