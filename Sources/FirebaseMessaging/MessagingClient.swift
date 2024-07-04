//
//  MessagingClient.swift
//
//
//  Created by Vamsi Madduluri on 05/07/24.
//

import Foundation
import AsyncHTTPClient
import NIO

public class MessagingClient {
    private let api: FirebaseAPIClient
    private let serviceAccount: ServiceAccount
    
    public init(serviceAccount: ServiceAccount) {
        self.serviceAccount = serviceAccount
        self.api = FirebaseAPIClient(serviceAccount: serviceAccount)
    }
    
    public func send(_ message: FcmMessage, dryRun: Bool = false) async throws {
        let endpoint = FirebaseEndpoint.messages(.send, projectID: serviceAccount.projectId)
        let request = try message.makeRequest(dryRun: dryRun)
        let response = try await api.httpClient.post(endpoint: endpoint, body: request)
        try api.throwIfError(response: response.0, body: response.1)
    }
}
