//
//  AuthPayload.swift
//
//
//  Created by Vamsi Madduluri on 04/07/24.
//

import Foundation
import AnyCodable
import JWTKit

public struct UserList: Codable, Sendable {
    public let userInfo: [UserRecord]
}

public struct UserRecord: Codable, Sendable{
    public let localID: String
    public let email, displayName: String?
    public let photoURL: String?
    public let emailVerified: Bool?
    public let providerUserInfo: [ProviderUserInfo]?
    public let validSince, lastLoginAt, createdAt, lastRefreshAt: String?
    
    enum CodingKeys: String, CodingKey {
        case localID = "localId"
        case email, displayName
        case photoURL = "photoUrl"
        case emailVerified, providerUserInfo, validSince, lastLoginAt, createdAt, lastRefreshAt
    }
}


// TODO: This could probably be filled out more.
public struct FirebaseContext: Codable, Sendable {
    enum CodingKeys: String, CodingKey {
        case signInProvider = "sign_in_provider"
        case tenant, identities
    }
    
    public let signInProvider: String?
    public let tenant: String?
    public let identities: [String: AnyCodable?]
}

public struct FirebaseJWTPayload: JWTPayload, Sendable {
    enum CodingKeys: String, CodingKey {
        case issuer = "iss"
        case subject = "sub"
        case audience = "aud"
        case issuedAt = "iat"
        case expirationAt = "exp"
        case email = "email"
        case userID = "user_id"
        case picture = "picture"
        case name = "name"
        case authTime = "auth_time"
        case isEmailVerified = "email_verified"
        case phoneNumber = "phone_number"
        case firebase = "firebase"
    }
    
    
    public let issuer: IssuerClaim
    public let issuedAt: IssuedAtClaim
    public let expirationAt: ExpirationClaim
    public let audience: AudienceClaim
    public let subject: SubjectClaim
    public let authTime: Date
    
    public let userID: String
    public let email: String?
    public let picture: String?
    public let name: String?
    public let isEmailVerified: Bool?
    public let phoneNumber: String?
    public let firebase: FirebaseContext
    
    // https://firebase.google.com/docs/auth/admin/verify-id-tokens
    public func verify(using signer: some JWTAlgorithm) throws {
        guard subject.value != "" else {
            throw JWTError.claimVerificationFailure(failedClaim: subject, reason: "Subject claim cannot be empty.")
        }
        
        guard issuedAt.value < Date() else {
            throw JWTError.claimVerificationFailure(failedClaim: issuedAt, reason: "Issued at claim must be in the past.")
        }
        
        guard authTime < Date() else {
            throw JWTError.claimVerificationFailure(failedClaim: expirationAt, reason: "Auth time claim must be in the past.")
        }
        
        guard expirationAt.value > Date() else {
            throw JWTError.claimVerificationFailure(failedClaim: expirationAt, reason: "Token expired at \(expirationAt.value)")
        }
        
        try expirationAt.verifyNotExpired()
    }
}

struct TokenRequest: Codable {
    let idToken: String
}

struct UserRequest: Codable {
    let localId: String
}

public struct LookupResponse: Codable, Sendable {
    public let users: [FirebaseUser]?
}

public struct FirebaseUser: Codable, Sendable {
    public let localId: String
    public let email: String?
    public let emailVerified: Bool?
    public let phoneNumber: String?
    public let displayName: String?
    public let photoUrl: String?
    public let providerUserInfo: [ProviderUserInfo]?
    public let passwordHash: String?
    public let passwordUpdatedAt: Double?
    public let validSince: String?
    public let lastLoginAt: String?
    public let createdAt: String?
    public let customAuth: Bool?
    public let customAttributes: String?
    public let providerId: String?
    public let tenantId: String?
}

public struct ProviderUserInfo: Codable, Sendable {
    public let providerId: String?
    public let federatedId: String?
    public let email: String?
    public let displayName: String?
    public let photoUrl: String?
    public let rawId: String?
    public let screenName: String?
}
