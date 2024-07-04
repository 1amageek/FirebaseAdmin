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

public class MessagingClient {
    private let api: FirebaseAPIClient
    private let serviceAccount: ServiceAccount
    
    public init(serviceAccount: ServiceAccount) {
        self.serviceAccount = serviceAccount
        self.api = FirebaseAPIClient(serviceAccount: serviceAccount)
    }
    
    // MARK: - Send FCM Message
    public func send(_ message: FcmMessage, dryRun: Bool = false) async throws {
        let endpoint = FirebaseEndpoint.messages(.send, projectID: serviceAccount.projectId).fullURL
        let responseData = try await api.makeAuthenticatedPost(
            endpoint: endpoint,
            body: FcmRequest(validateOnly: dryRun, message: message)
        ).get()
    }
}
