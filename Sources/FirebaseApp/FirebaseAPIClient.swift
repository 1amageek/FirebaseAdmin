//
//  FirebaseAuthClient.swift
//
//
//  Created by Vamsi Madduluri on 04/07/24.
//

import Foundation
import AsyncHTTPClient
import NIOCore
import NIOHTTP1
import JWTKit

public struct FirebaseError: Codable {
    public let code: Int?
    public let message: String?
}

public struct FirebaseErrorResponse: Codable, Error {
    public let error: FirebaseError
}

public class FirebaseAPIClient {
    
    let httpClient: HTTPClient
    var serviceAccount: ServiceAccount?
    let endpoint: FirebaseEndpoint
    
    public init(serviceAccount: ServiceAccount? = nil) {
        self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        self.serviceAccount = serviceAccount
        self.endpoint = FirebaseEndpoint()
    }
    
    deinit {
        // Use shutdown to ensure no event loop issues
        httpClient.shutdown { error in
            if let error = error {
                print("Error shutting down HTTPClient: \(error)")
            }
        }
    }
    
    public func throwIfError(response: HTTPClient.Response, body: ByteBuffer) throws {
        if let error = try? JSONDecoder().decode(FirebaseErrorResponse.self, from: body) {
            throw error
        }
    }
    
    public func decodeOrThrow<T: Codable>(response: HTTPClient.Response, body: ByteBuffer) throws -> T {
        if let decoded = try? JSONDecoder().decode(T.self, from: body) {
            return decoded
        }
        try throwIfError(response: response, body: body)
        throw NSError(domain: "FirebaseAPIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])
    }
    
    public func makeAuthenticatedPost(endpoint: String, body: Codable? = nil) async throws -> (HTTPClient.Response, ByteBuffer) {
        let token = try await getOAuthToken()
        var request = try HTTPClient.Request(url: endpoint, method: .POST)
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Authorization", value: "Bearer \(token.access_token)")
        if let body = body {
            request.body = .data(try JSONEncoder().encode(body))
        }
        // Execute the request and return HTTPClientResponse, ByteBuffer
        let response = try await httpClient.execute(request: request).get()
        let body = response.body ?? ByteBufferAllocator().buffer(capacity: 0)
        return (response, body)
    }
    
    func getOAuthToken() async throws -> OAuthTokenResponse {
        // Implement caching logic here
        // For simplicity, we'll just get a new token each time
        return try await getNewOAuthToken()
    }
    
    func getNewOAuthToken() async throws -> OAuthTokenResponse {
        guard let serviceAccount = serviceAccount else {
            throw NSError(domain: "FirebaseAPIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Service account not set"])
        }
        
        let scopes = "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/datastore https://www.googleapis.com/auth/devstorage.full_control https://www.googleapis.com/auth/firebase https://www.googleapis.com/auth/identitytoolkit https://www.googleapis.com/auth/userinfo.email"
        
        let privateKey = try RSAKey.private(pem: serviceAccount.privateKeyPem)
        let signers = JWTSigners()
        signers.use(.rs256(key: privateKey), kid: JWKIdentifier(string: serviceAccount.privateKeyId))
        
        let jwt = try signers.sign(FirebaseAdminAuthPayload(
            scope: scopes,
            issuer: .init(stringLiteral: serviceAccount.clientEmail),
            audience: .init(stringLiteral: serviceAccount.tokenUri))
        )
        
        var request = try HTTPClient.Request(url: serviceAccount.tokenUri, method: .POST)
        request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
        request.headers.add(name: "Authorization", value: "Bearer \(jwt)")
        request.body = .string("grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)")
        let response = try await httpClient.execute(request: request).get()
        let body = response.body
        
        guard let body = body else {
            throw NSError(domain: "FirebaseAPIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "No response body"])
        }
        
        guard let parsed = try? JSONDecoder().decode(OAuthTokenResponse.self, from: body) else {
            throw NSError(domain: "FirebaseAPIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get OAuth token"])
        }
        return parsed
    }
}


struct OAuthTokenResponse: Codable {
    static let cacheKey = "OauthTokenResponse"
    let access_token: String
    let expires_in: Int
    let token_type: String
}

struct TokenFormRequest: Codable {
    var grant_type: String
    var assertion: String
}

struct FirebaseAdminAuthPayload: JWTPayload {
    enum CodingKeys: String, CodingKey {
        case expiration = "exp"
        case audience = "aud"
        case algorithm = "alg"
        case issuer = "iss"
        case issuedAt = "iat"
        case scope = "scope"
    }
    
    var scope: String
    var issuer: IssuerClaim
    var algorithm = "RS256"
    var issuedAt: IssuedAtClaim = .init(value: Date())
    var audience: AudienceClaim
    var expiration: ExpirationClaim = .init(value: Date().addingTimeInterval(.seconds(1000)))
    
    func verify(using signer: JWTSigner) throws {
        try self.expiration.verifyNotExpired()
    }
}


extension TimeInterval {
    static func seconds(_ val: Double) -> Self {
        return val
    }
    
    static func minutes(_ val: Double) -> Self {
        return val * .seconds(60)
    }
    
    static func hours(_ val: Double) -> Self {
        return val * .minutes(60)
    }
    
    static func days(_ val: Double) -> Self {
        return val * .hours(24)
    }
}
