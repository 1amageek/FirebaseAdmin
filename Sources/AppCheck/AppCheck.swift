//
//  AppCheck.swift
//
//
//  Created by Norikazu Muramoto on 2023/05/11.
//

import Foundation
import JWTKit
import AsyncHTTPClient
import NIO
import CryptoKit

public enum AppCheckError: Error {
    case invalidPublicKey
    case invalidToken
}

public class AppCheck {
    
    private let jwksURL: String = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"
    
    private var jwks: JWKS?
    
    public init(publicKey: String? = nil) {
        if let publicKey, let data = publicKey.data(using: .utf8) {
            do {
                self.jwks = try JSONDecoder().decode(JWKS.self, from: data)
            } catch {
                print("Failed to decode JWKS: \(error)")
            }
        }
    }
    
    func fetch(client: HTTPClient) async throws -> JWKS {
        let response = try await client.get(url: jwksURL).get()
        return try JSONDecoder().decode(JWKS.self, from: response.body!)
    }
    
    public func validate(token: String) async throws -> Bool {
        if jwks == nil {
            throw AppCheckError.invalidPublicKey
        }
        guard let jwks else {
            return false
        }
        let signers: JWTKeyCollection = JWTKeyCollection()
        
        let jsonEncoder = JSONEncoder()
        let jwksData = try jsonEncoder.encode(jwks)
        let jwksJSON = String(data: jwksData, encoding: .utf8)!
        
        try await signers.use(jwksJSON: jwksJSON)
        _ = try await signers.verify(token, as: Payload.self)
        return true
    }
    
    public func validate(token: String, client: HTTPClient) async throws -> Bool {
        if jwks == nil {
            self.jwks = try await fetch(client: client)
        }
        return try await validate(token: token)
    }
}

struct Payload: JWTPayload {
    
    var iss: IssuerClaim
    var sub: SubjectClaim
    var aud: AudienceClaim
    var iat: IssuedAtClaim
    var exp: ExpirationClaim
    
    func verify(using signer: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}
