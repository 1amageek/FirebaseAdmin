//
//  ServiceAccount.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

// Defining a public struct named ServiceAccount which conforms to Codable protocol
public struct ServiceAccount: Codable, Sendable {
    public let type: String
    public let projectId: String
    public let privateKeyId: String
    public let privateKeyPem: String
    public let clientEmail: String
    public let clientId: String
    public let authUri: String
    public let tokenUri: String
    public let authProviderX509CertUrl: String
    public let clientX509CertUrl: String

    private enum CodingKeys: String, CodingKey {
        case type
        case projectId = "project_id"
        case privateKeyId = "private_key_id"
        case privateKeyPem = "private_key"
        case clientEmail = "client_email"
        case clientId = "client_id"
        case authUri = "auth_uri"
        case tokenUri = "token_uri"
        case authProviderX509CertUrl = "auth_provider_x509_cert_url"
        case clientX509CertUrl = "client_x509_cert_url"
    }
}
