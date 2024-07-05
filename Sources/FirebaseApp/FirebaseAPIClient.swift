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

public struct FirebaseError: Codable {
    public let code: Int?
    public let message: String?
}

public struct FirebaseErrorResponse: Codable, Error {
    public let error: FirebaseError
}

public enum FirebaseAPIError: Error {
    case serviceAccountNotSet
    case missingResponseBody
    case invalidResponse
}

public class FirebaseAPIClient {
    
    let httpClient: HTTPClient
    var serviceAccount: ServiceAccount?
    let endpoint: FirebaseEndpoint
    let decoder: JSONDecoder
    let eventLoopGroup: EventLoopGroup
    
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
    
    public func makeAuthenticatedPost<T: Codable>(endpoint: String, body: Codable? = nil) -> EventLoopFuture<T> {
        return getOAuthToken().flatMap { token in
            do {
                var request = try HTTPClient.Request(url: endpoint, method: .POST)
                request.headers.add(name: "Content-Type", value: "application/json")
                request.headers.add(name: "Authorization", value: "Bearer \(token.access_token)")
                if let body = body {
                    request.body = .data(try JSONEncoder().encode(body))
                }
                
                return self.httpClient.execute(request: request).flatMap { response in
                    guard var byteBuffer = response.body else {
                        return self.httpClient.eventLoopGroup.next().makeFailedFuture(FirebaseAPIError.missingResponseBody)
                    }
                    let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
                    
                    do {
                        guard response.status == .ok else {
                            return self.httpClient.eventLoopGroup.next().makeFailedFuture(try self.decoder.decode(FirebaseErrorResponse.self, from: responseData))
                        }
                        return self.httpClient.eventLoopGroup.next().makeSucceededFuture(try self.decoder.decode(T.self, from: responseData))
                    } catch {
                        return self.httpClient.eventLoopGroup.next().makeFailedFuture(error)
                    }
                }
            } catch {
                return self.httpClient.eventLoopGroup.next().makeFailedFuture(error)
            }
        }
    }
    
    public func makeAuthenticatedPost(endpoint: String, body: Encodable? = nil) -> EventLoopFuture<Data> {
        return getOAuthToken().flatMap { token in
            do {
                var request = try HTTPClient.Request(url: endpoint, method: .POST)
                request.headers.add(name: "Content-Type", value: "application/json")
                request.headers.add(name: "Authorization", value: "Bearer \(token.access_token)")
                if let body = body {
                    request.body = .data(try JSONEncoder().encode(body))
                }
                
                return self.httpClient.execute(request: request).flatMap { response in
                    guard var byteBuffer = response.body else {
                        return self.httpClient.eventLoopGroup.next().makeFailedFuture(FirebaseAPIError.missingResponseBody)
                    }
                    let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
                    
                    if response.status == .ok {
                        return self.httpClient.eventLoopGroup.next().makeSucceededFuture(responseData)
                    } else {
                        do {
                            let errorResponse = try self.decoder.decode(FirebaseErrorResponse.self, from: responseData)
                            return self.httpClient.eventLoopGroup.next().makeFailedFuture(errorResponse)
                        } catch {
                            return self.httpClient.eventLoopGroup.next().makeFailedFuture(error)
                        }
                    }
                }
            } catch {
                return self.httpClient.eventLoopGroup.next().makeFailedFuture(error)
            }
        }
    }
    
    private func getOAuthToken() -> EventLoopFuture<OAuthTokenResponse> {
        // Implement token caching logic here if needed
        return getNewOAuthToken()
    }
    
    private func getNewOAuthToken() -> EventLoopFuture<OAuthTokenResponse> {
        guard let serviceAccount = serviceAccount else {
            return httpClient.eventLoopGroup.next().makeFailedFuture(FirebaseAPIError.serviceAccountNotSet)
        }
        
        do {
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
            request.body = .string("grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=\(jwt)")
            
            return httpClient.execute(request: request).flatMap { response in
                guard var byteBuffer = response.body else {
                    return self.httpClient.eventLoopGroup.next().makeFailedFuture(FirebaseAPIError.missingResponseBody)
                }
                let responseData = byteBuffer.readData(length: byteBuffer.readableBytes)!
                
                do {
                    return self.httpClient.eventLoopGroup.next().makeSucceededFuture(try self.decoder.decode(OAuthTokenResponse.self, from: responseData))
                } catch {
                    return self.httpClient.eventLoopGroup.next().makeFailedFuture(error)
                }
            }
        } catch {
            return httpClient.eventLoopGroup.next().makeFailedFuture(error)
        }
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
