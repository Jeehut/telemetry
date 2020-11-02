import Fluent
import Vapor

struct UsersController: RouteCollection {
    enum RegistrationStatus: String {
        case closed
        case tokenOnly
        case open
    }
    
    let currentRegistrationStatus: RegistrationStatus = .tokenOnly
    
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("registrationStatus", use: getRegistrationStatus)
        routes.post("register", use: create)
        
        let passwordProtected = routes.grouped(User.authenticator())
        passwordProtected.post("login", use: getBearerTokenForUser)
        
        let tokenProtected = routes.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: getUserInformation)
        tokenProtected.post("updatePassword", use: updatePassword)
    }

    /// Return the canonical hashed version of the given password string
    static func hash(from password: String) -> String {
        // TODO: Salt that hash, mofo!
        let hashedPassword = try! Bcrypt.hash(password)

        return hashedPassword
    }
    
    struct RegistrationRequestBody: Content, Validatable {
        let registrationToken: String?
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
            let hashedPassword = UsersController.hash(from: self.userPassword)

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

    struct PasswordChangeRequestBody: Content, Validatable {
        let oldPassword: String
        let newPassword: String
        let newPasswordConfirm: String

        static func validations(_ validations: inout Validations) {
            validations.add("oldPassword", as: String.self, is: !.empty)
            validations.add("newPassword", as: String.self, is: !.empty)
            validations.add("newPasswordConfirm", as: String.self, is: !.empty)
            validations.add("newPassword", as: String.self, is: .count(8...))
        }
    }
    
    func getRegistrationStatus(req: Request) throws -> [String: String] {
        return ["registrationStatus": self.currentRegistrationStatus.rawValue]
    }
    
    /// Register and Create a new Organization
    func create(req: Request) throws -> EventLoopFuture<UserDataTransferObject> {
        try RegistrationRequestBody.validate(content: req)
        let registrationRequestBody = try req.content.decode(RegistrationRequestBody.self)
        
        guard registrationRequestBody.userPassword == registrationRequestBody.userPasswordConfirm else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        
        let org = registrationRequestBody.makeOrganisation()
        
        switch currentRegistrationStatus {
        
        case .closed:
            throw Abort(.badRequest, reason: "Registration is currently closed")
        case .tokenOnly:
            guard registrationRequestBody.registrationToken?.isEmpty == false else {
                throw Abort(.badRequest, reason: "Registration needs a registrationToken")
            }
            
            return BetaRequestEmail.query(on: req.db)
                .filter(\.$registrationToken == registrationRequestBody.registrationToken!)
                .filter(\.$isFulfilled == false)
                .first()
                .unwrap(or: Abort(.notFound))
                .flatMap { betaRequestEmail in
                    betaRequestEmail.isFulfilled = true
                    _ = betaRequestEmail.save(on: req.db)
                    
                    return org.create(on: req.db).flatMap {
                        let user = registrationRequestBody.makeUser(organizationID: org.id!)
                        return user.create(on: req.db).map { UserDataTransferObject(user: user) }
                    }
                }
        case .open:
            return org.create(on: req.db).flatMap {
                let user = registrationRequestBody.makeUser(organizationID: org.id!)
                return user.create(on: req.db)
                    .map { UserDataTransferObject(user: user) }
            }
        }
    }
    
    func getBearerTokenForUser(req: Request) throws -> EventLoopFuture<UserToken> {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: req.db)
            .map { token }
    }
    
    func getUserInformation(req: Request) throws -> EventLoopFuture<UserDataTransferObject> {
        let user = try req.auth.require(User.self)
        return user.$organization.load(on: req.db).map { UserDataTransferObject(user: user) }
    }


    /// Updates the user's password and deletes all user tokens. The user will have to log in again.
    func updatePassword(req: Request) throws -> EventLoopFuture<UserDataTransferObject> {
        try PasswordChangeRequestBody.validate(content: req)
        let passwordChangeRequestBody = try req.content.decode(PasswordChangeRequestBody.self)

        guard passwordChangeRequestBody.newPassword == passwordChangeRequestBody.newPasswordConfirm else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }

        let user = try req.auth.require(User.self)

        guard try user.verify(password: passwordChangeRequestBody.oldPassword) else {
            throw Abort(.badRequest, reason: "Incorrect Old Password")
        }

        user.passwordHash = Self.hash(from: passwordChangeRequestBody.newPassword)
        return user.save(on: req.db)
            .flatMap {
                UserToken.query(on: req.db)
                    .filter(\.$user.$id == user.id!)
                    .delete()
            }
            .map { UserDataTransferObject(user: user) }
    }
}
