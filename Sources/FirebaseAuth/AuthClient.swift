//
//  AuthClient.swift
//
//
//  Created by Vamsi Madduluri on 04/07/24.
//

import Foundation
import JWTKit
import AsyncHTTPClient
import NIO

public enum AuthError: Error {
    case invalidAudience
    case invalidIssuer
    case failedToResolveJWKS
    case userNotFound
    case deletionFailed
    case httpClientInitializationFailed
    case decodingFailed
}

@globalActor public actor AuthActor {
    public static let shared = AuthActor()
    private init() {}
}

@AuthActor
public class AuthClient: Sendable {
    private let jwksURL = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
    private let api: FirebaseAPIClient
    private let serviceAccount: ServiceAccount

    public init(serviceAccount: ServiceAccount) async {
        self.serviceAccount = serviceAccount
        self.api = await FirebaseAPIClient(serviceAccount: serviceAccount)
    }

    public func validate(idToken: String) async throws -> FirebaseJWTPayload {
        let result: FirebaseJWTPayload
        do {
            result = try await verify(idToken: idToken)
        } catch {
            // It's possible Google has rotated the JWT keys, so if we get any kind of failure - let's try one more time
            result = try await verify(idToken: idToken, forceRefresh: true)
        }

        guard result.audience.value.first == serviceAccount.projectId else {
            throw AuthError.invalidAudience
        }

        guard let url = URL(string: result.issuer.value),
              let expectedUrl = URL(string: "https://securetoken.google.com/\(serviceAccount.projectId)"),
              url == expectedUrl else {
            throw AuthError.invalidIssuer
        }

        return result
    }

    private func verify(idToken: String, forceRefresh: Bool = false) async throws -> FirebaseJWTPayload {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        let googleCert = try await httpClient.get(url: jwksURL).get()
        try await httpClient.shutdown()
        try await eventLoopGroup.shutdownGracefully()
        let jwks = try JSONDecoder().decode(JWKS.self, from: googleCert.body!)
        guard !jwks.keys.isEmpty else {
            throw AuthError.failedToResolveJWKS
        }
        let signers = JWTKeyCollection()
        try await signers.use(jwks: jwks)
        return try await signers.verify(idToken, as: FirebaseJWTPayload.self)
    }

    public func getUser(uid: String) async throws -> FirebaseUser {
        let endpoint = await api.endpoint(for: .lookup).fullURL
        let userResponse: LookupResponse = try await api.makeAuthenticatedPost(
            endpoint: endpoint,
            body: UserRequest(localId: uid)
        )

        guard let user = userResponse.users?.first else {
            throw AuthError.userNotFound
        }

        return user
    }

    public func getUsers() async throws -> [UserRecord] {
        let endpoint = await api.endpoint(for: .query).fullURL
        let usersResponse: UserList = try await api.makeAuthenticatedPost(endpoint: endpoint)
        return usersResponse.userInfo
    }

    public func deleteUser(uid: String) async throws {
        let endpoint = await api.endpoint(for: .delete).fullURL
        let _: EmptyResponse = try await api.makeAuthenticatedPost(
            endpoint: endpoint,
            body: UserRequest(localId: uid)
        )
    }
}

extension JWTKeyCollection {
    @discardableResult
    public func use(jwks: JWKS) throws -> Self {
        return try self.add(jwks: jwks)
    }
}

struct EmptyResponse: Codable {}
