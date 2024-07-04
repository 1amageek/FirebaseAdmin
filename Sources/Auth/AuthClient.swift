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
}

public class AuthClient {
    private let jwksURL = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
    private let api: FirebaseAPIClient
    private let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
    private let serviceAccount: ServiceAccount

    init(serviceAccount: ServiceAccount) {
        self.serviceAccount = serviceAccount
        self.api = FirebaseAPIClient(serviceAccount: serviceAccount)
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
        let googleCert = try await httpClient.get(url: jwksURL).get()
        let jwks = try JSONDecoder().decode(JWKS.self, from: googleCert.body!)
        
        guard !jwks.keys.isEmpty else {
            throw AuthError.failedToResolveJWKS
        }
        
        let signers = JWTSigners()
        try signers.use(jwks: jwks)
        
        return try signers.verify(idToken, as: FirebaseJWTPayload.self)
    }
    
    public func getUser(uid: String) async throws -> FirebaseUser {
        let endpoint = api.endpoint(for: .lookup).fullURL
        let (response, body) = try await api.makeAuthenticatedPost(
            endpoint: endpoint,
            body: UserRequest(localId: uid))
        
        let userResponse: LookupResponse = try api.decodeOrThrow(response: response, body: body)
        guard let user = userResponse.users?.first else {
            throw AuthError.userNotFound
        }
        return user
    }

    
    public func getUsers() async throws -> [UserRecord] {
        let endpoint = api.endpoint(for: .query).fullURL
        let (response, body) = try await api.makeAuthenticatedPost(endpoint: endpoint)
        
        let usersResponse: UserList = try api.decodeOrThrow(response: response, body: body)
        return usersResponse.userInfo
    }
    
    public func deleteUser(uid: String) async throws {
        let endpoint = api.endpoint(for: .delete).fullURL
        let (response, body) = try await api.makeAuthenticatedPost(
            endpoint: endpoint,
            body: UserRequest(localId: uid))
        if response.status == .ok {
            return
        }
        try api.throwIfError(response: response, body: body)
        throw AuthError.deletionFailed
    }
}


