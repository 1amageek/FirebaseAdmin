//
//  AccessTokenProvider.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import Foundation
#if canImport(Swift.Concurrency)
import Swift.Concurrency
#endif
import JWTKit

struct AccessTokenPayload: JWTPayload {
    var iss: IssuerClaim
    var sub: SubjectClaim
    var aud: AudienceClaim
    var iat: IssuedAtClaim
    var exp: ExpirationClaim
    var scope: String

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }
}

let GOOGLE_TOKEN_AUDIENCE = "https://accounts.google.com/o/oauth2/token"
let GOOGLE_AUTH_TOKEN_HOST = "accounts.google.com"
let GOOGLE_AUTH_TOKEN_PATH = "/o/oauth2/token"

public protocol AccessScope {
    var value: String { get }
}

public struct AccessTokenProvider {

    private let serviceAccount: ServiceAccount

    private let signer: JWTSigner
    
    public init(serviceAccount: ServiceAccount) throws {
        self.serviceAccount = serviceAccount
        let privateKey = try RSAKey.private(pem: serviceAccount.privateKeyPem)
        self.signer = JWTSigner.rs256(key: privateKey)
    }
    
    public func fetchAccessToken(_ scope: AccessScope) async throws -> String {
        let jwt = AccessTokenPayload(
            iss: IssuerClaim(value: serviceAccount.clientEmail),
            sub: SubjectClaim(value: serviceAccount.clientEmail),
            aud: AudienceClaim(value: GOOGLE_TOKEN_AUDIENCE),
            iat: IssuedAtClaim(value: Date()),
            exp: ExpirationClaim(value: Date(timeIntervalSinceNow: 3600)),
            scope: scope.value
        )
        
        let token = try signer.sign(jwt)
        let accessToken = try await requestAccessToken(signedJwt: token)
        return accessToken
    }
    
//    private func requestAccessToken(signedJwt: String) async throws -> String {
//        let url = URL(string: "https://\(GOOGLE_AUTH_TOKEN_HOST)\(GOOGLE_AUTH_TOKEN_PATH)")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        let body = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=\(signedJwt)"
//        request.httpBody = body.data(using: .utf8)
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//            throw NSError(domain: "FirestoreAccessTokenProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from token endpoint"])
//        }
//
//        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//        guard let accessToken = json?["access_token"] as? String else {
//            throw NSError(domain: "FirestoreAccessTokenProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found in token endpoint response"])   }
//        return accessToken
//    }

    private func requestAccessToken(signedJwt: String) async throws -> String {
        let url = URL(string: "https://\(GOOGLE_AUTH_TOKEN_HOST)\(GOOGLE_AUTH_TOKEN_PATH)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let body = "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=\(signedJwt)"
        request.httpBody = body.data(using: .utf8)

        return try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    continuation.resume(throwing: NSError(domain: "FirestoreAccessTokenProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from token endpoint"]))
                    return
                }

                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let accessToken = json["access_token"] as? String else {
                    continuation.resume(throwing: NSError(domain: "FirestoreAccessTokenProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access token not found in token endpoint response"]))
                    return
                }

                continuation.resume(returning: accessToken)
            }
            task.resume()
        }
    }
}
