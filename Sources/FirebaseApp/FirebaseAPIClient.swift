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
import NIOFoundationCompat
import NIO

public struct FirebaseError: Codable, Sendable {
    public let code: Int?
    public let message: String?
}

public struct FirebaseErrorResponse: Codable, Error, Sendable {
    public let error: FirebaseError
}

public enum FirebaseAPIError: Error, Sendable {
    case serviceAccountNotSet
    case missingResponseBody
    case invalidResponse
}

@globalActor public actor FirebaseActor {
    public static let shared = FirebaseActor()
    private init() {}
}

@FirebaseActor
public class FirebaseAPIClient: Sendable {
    
    private let httpClient: HTTPClient
    private var serviceAccount: ServiceAccount?
    private let endpoint: FirebaseEndpoint
    private let decoder: JSONDecoder
    private let eventLoopGroup: EventLoopGroup
    
    public var projectId: String? {
        serviceAccount?.projectId
    }
    
    public init(serviceAccount: ServiceAccount? = nil) {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        self.httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        self.serviceAccount = serviceAccount
        self.endpoint = FirebaseEndpoint()
        self.decoder = JSONDecoder()
    }
    
    deinit {
        try? httpClient.shutdown()
    }
    
    private func throwIfError(response: HTTPClient.Response, body: ByteBuffer) throws {
        if let error = try? JSONDecoder().decode(FirebaseErrorResponse.self, from: body) {
            throw error
        }
    }
    
    private func decodeOrThrow<T: Codable>(response: HTTPClient.Response, body: ByteBuffer) throws -> T {
        if let decoded = try? JSONDecoder().decode(T.self, from: body) {
            return decoded
        }
        try throwIfError(response: response, body: body)
        throw NSError(domain: "FirebaseAPIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse response"])
    }
    
    public func makeAuthenticatedPost<T: Codable>(endpoint: String, body: (any Codable)? = nil) async throws -> T {
        let token = try await getOAuthToken()
        var request = try HTTPClient.Request(url: endpoint, method: .POST)
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Authorization", value: "Bearer \(token.access_token)")
        if let body = body {
            request.body = .data(try JSONEncoder().encode(body))
        }
        
        let response = try await httpClient.execute(request: request).get()
        guard var byteBuffer = response.body else {
            throw FirebaseAPIError.missingResponseBody
        }
        let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
        
        guard response.status == .ok else {
            throw try decoder.decode(FirebaseErrorResponse.self, from: responseData)
        }
        return try decoder.decode(T.self, from: responseData)
    }
    
    public func makeAuthenticatedPost(endpoint: String, body: (any Encodable)? = nil) async throws -> Data {
        let token = try await getOAuthToken()
        var request = try HTTPClient.Request(url: endpoint, method: .POST)
        request.headers.add(name: "Content-Type", value: "application/json")
        request.headers.add(name: "Authorization", value: "Bearer \(token.access_token)")
        if let body = body {
            request.body = .data(try JSONEncoder().encode(body))
        }
        
        let response = try await httpClient.execute(request: request).get()
        guard var byteBuffer = response.body else {
            throw FirebaseAPIError.missingResponseBody
        }
        let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
        
        if response.status == .ok {
            return responseData
        } else {
            throw try decoder.decode(FirebaseErrorResponse.self, from: responseData)
        }
    }
    
    private func getOAuthToken() async throws -> OAuthTokenResponse {
        // Implement token caching logic here if needed
        return try await getNewOAuthToken()
    }
    
    private func getNewOAuthToken() async throws -> OAuthTokenResponse {
        guard let serviceAccount = serviceAccount else {
            throw FirebaseAPIError.serviceAccountNotSet
        }
        
        let scopes = "https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/datastore https://www.googleapis.com/auth/devstorage.full_control https://www.googleapis.com/auth/firebase https://www.googleapis.com/auth/identitytoolkit https://www.googleapis.com/auth/userinfo.email"
        
        let privateKey = try Insecure.RSA.PrivateKey(pem: serviceAccount.privateKeyPem)
        let keyCollection = await JWTKeyCollection()
            .add(rsa: privateKey, digestAlgorithm: .sha256, kid: JWKIdentifier(string: serviceAccount.privateKeyId))
        
        let payload = FirebaseAdminAuthPayload(
            scope: scopes,
            issuer: .init(stringLiteral: serviceAccount.clientEmail),
            audience: .init(stringLiteral: serviceAccount.tokenUri)
        )
        
        let jwt = try await keyCollection.sign(payload, kid: JWKIdentifier(string: serviceAccount.privateKeyId))
        
        var request = try HTTPClient.Request(url: serviceAccount.tokenUri, method: .POST)
        request.headers.add(name: "Content-Type", value: "application/x-www-form-urlencoded")
        request.body = .string("grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)")
        
        let response = try await httpClient.execute(request: request).get()
        guard var byteBuffer = response.body else {
            throw FirebaseAPIError.missingResponseBody
        }
        let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
        
        return try decoder.decode(OAuthTokenResponse.self, from: responseData)
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
    
    func verify(using signer: some JWTAlgorithm) throws {
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
