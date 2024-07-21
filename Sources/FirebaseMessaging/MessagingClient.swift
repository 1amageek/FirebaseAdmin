//
//  MessagingClient.swift
//
//
//  Created by Vamsi Madduluri on 05/07/24.
//

import Foundation
import JWTKit
import AsyncHTTPClient
import NIO

@globalActor public actor MessagingActor {
    public static let shared = MessagingActor()
    private init() {}
}

@MessagingActor
public class MessagingClient {
    private let api: FirebaseAPIClient
    private let serviceAccount: ServiceAccount
    
    public init(serviceAccount: ServiceAccount) async {
        self.serviceAccount = serviceAccount
        self.api = await FirebaseAPIClient(serviceAccount: serviceAccount)
    }
    
    // MARK: - Send FCM Message
    public func send(_ message: FcmMessage, dryRun: Bool = false) async throws {
        let endpoint = FirebaseEndpoint.messages(.send, projectID: serviceAccount.projectId).fullURL
        let request = FcmRequest(validateOnly: dryRun, message: message)
        let responseData = try await api.makeAuthenticatedPost(
            endpoint: endpoint,
            body: request
        )
    }
}
