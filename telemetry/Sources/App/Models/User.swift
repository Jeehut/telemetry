import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String
    
    /// if true, this user may not be deleted
    @Field(key: "is_founding_user")
    var isFoundingUser: Bool

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Parent(key: "organization_id")
    var organization: Organization

    init() { }

    init(id: UUID? = nil, firstName: String, lastName: String, isFoundingUser: Bool, email: String, passwordHash: String, organizationID: UUID) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isFoundingUser = isFoundingUser
        self.email = email
        self.passwordHash = passwordHash
        self.$organization.id = organizationID
    }
}

struct UserDataTransferObject: Content {
    let id: UUID
    let organization: Organization?
    let isFoundingUser: Bool
    let firstName: String
    let lastName: String
    let email: String
    
    init(user: User) {
        self.id = user.id!
        self.organization = user.$organization.value
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.email = user.email
        self.isFoundingUser = user.isFoundingUser
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    /// Used for email/password login in order to generate Tokens
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    /// Return the canonical hashed version of the given password string
    static func hash(from password: String) -> String {
        // TODO: Salt that hash, mofo!
        let hashedPassword = try! Bcrypt.hash(password)

        return hashedPassword
    }

    /// Used to generate login tokens for use in the rest of the API
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
