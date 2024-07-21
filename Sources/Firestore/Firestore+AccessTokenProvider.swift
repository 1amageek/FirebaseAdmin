//
//  AccessTokenProvider.swift
//
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation
import FirestoreAPI
import AsyncHTTPClient
import NIO
import NIOFoundationCompat
import JWTKit

struct AccessTokenPayload: JWTPayload {
    var iss: IssuerClaim
    var sub: SubjectClaim
    var aud: AudienceClaim
    var iat: IssuedAtClaim
    var exp: ExpirationClaim
    var scope: String

    func verify(using signer: some JWTAlgorithm) throws {
        try self.exp.verifyNotExpired()
    }
}

let GOOGLE_TOKEN_AUDIENCE = "https://accounts.google.com/o/oauth2/token"
let GOOGLE_AUTH_TOKEN_HOST = "accounts.google.com"
let GOOGLE_AUTH_TOKEN_PATH = "/o/oauth2/token"

public protocol AccessScope {
    var value: String { get }
}

public class AccessTokenProvider: FirestoreAPI.AccessTokenProvider {

    private let serviceAccount: ServiceAccount

    private let signer: JWTKeyCollection

    public var scope: FirestoreAPI.AccessScope { Firestore.Scope() }

    var accessToken: String?

    var expireTime: Date?

    public init(serviceAccount: ServiceAccount) throws {
        self.serviceAccount = serviceAccount
        self.signer = JWTKeyCollection()
    }

    /**
     Retrieves an access token for the Firestore database.

     Use this method to retrieve an access token for the Firestore database. If an access token has already been retrieved, this method returns it. Otherwise, it initializes an `AccessTokenProvider` instance with the `FirebaseApp` service account and retrieves a new access token using the `Scope` struct. The access token is then stored in the `accessToken` property of the `Firestore` instance and returned.

     - Returns: An access token for the Firestore database.
     - Throws: A `ServiceAccountError` if an error occurs while initializing the `AccessTokenProvider` instance or retrieving the access token.
     */
    public func getAccessToken(expirationDuration: TimeInterval) async throws -> String {
        if let token = accessToken, let expiration = expireTime, expiration > Date() {
            return token
        }
        let accessToken = try await fetchAccessToken(scope, expirationDuration: expirationDuration)
        self.accessToken = accessToken
        self.expireTime = Date(timeIntervalSinceNow: expirationDuration)
        return accessToken
    }

    private func fetchAccessToken(_ scope: FirestoreAPI.AccessScope, expirationDuration: TimeInterval) async throws -> String {
        let jwt = AccessTokenPayload(
            iss: IssuerClaim(value: serviceAccount.clientEmail),
            sub: SubjectClaim(value: serviceAccount.clientEmail),
            aud: AudienceClaim(value: GOOGLE_TOKEN_AUDIENCE),
            iat: IssuedAtClaim(value: Date()),
            exp: ExpirationClaim(value: Date(timeIntervalSinceNow: expirationDuration)),
            scope: scope.value
        )
        let privateKey = try Insecure.RSA.PrivateKey(pem: serviceAccount.privateKeyPem)
        await signer.add(rsa: privateKey, digestAlgorithm: .sha256)
        let token = try await signer.sign(jwt)
        let accessToken = try await requestAccessToken(signedJwt: token)
        return accessToken
    }

    private func requestAccessToken(signedJwt: String) async throws -> String {
        let url = URL(string: "https://\(GOOGLE_AUTH_TOKEN_HOST)\(GOOGLE_AUTH_TOKEN_PATH)")!
        var configuration = HTTPClient.Configuration()
        configuration.tlsConfiguration = .clientDefault
        configuration.tlsConfiguration?.certificateVerification = .none
        configuration.httpVersion = .automatic
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let client = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        let body = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=\(signedJwt)"
        let request = try HTTPClient.Request(
            url: url,
            method: .POST,
            headers: .init([
                ("Content-Type", "application/x-www-form-urlencoded")
            ]),
            body: HTTPClient.Body.data(body.data(using: .utf8)!)
        )
        let response = try await client.execute(request: request).get()
        try await client.shutdown()
        try await eventLoopGroup.shutdownGracefully()
        guard
            var body = response.body,
            let responseBodyData = body.readData(length: body.readableBytes)
        else {
            throw NSError(domain: "FirestoreAccessTokenProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from token endpoint"])
        }
        guard
            let json = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: Any],
            let accessToken = json["access_token"] as? String else {
            throw NSError(domain: "FirestoreAccessTokenProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found in token endpoint response"])
        }
        return accessToken
    }

}
