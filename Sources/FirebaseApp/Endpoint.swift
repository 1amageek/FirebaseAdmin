//
//  Endpoint.swift
//
//
//  Created by Vamsi Madduluri on 04/07/24.
//

import Foundation

public struct FirebaseEndpoint {
    
    let baseURL: String
    let path: String
    
    var fullURL: String {
        return baseURL + path
    }
    
    init(baseURL: String = "https://firebase.googleapis.com", path: String = "/v1beta1/availableProjects") {
        self.baseURL = baseURL
        self.path = path
    }
    
    public enum Auth {
        case query
        case delete
        case lookup
        
        var path: String {
            switch self {
            case .query: return "accounts:query"
            case .delete: return "accounts:delete"
            case .lookup: return "accounts:lookup"
            }
        }
    }
    
    public enum Messages {
        case send
        
        var path: String {
            switch self {
            case .send: return "messages:send"
            }
        }
    }
    
    public static func auth(_ endpoint: Auth, projectID: String) -> FirebaseEndpoint {
        FirebaseEndpoint(
            baseURL: "https://identitytoolkit.googleapis.com/v1/projects/\(projectID)/",
            path: endpoint.path
        )
    }
    
    public static func messages(_ endpoint: Messages, projectID: String) -> FirebaseEndpoint {
        FirebaseEndpoint(
            baseURL: "https://fcm.googleapis.com/v1/projects/\(projectID)/",
            path: endpoint.path
        )
    }
}

extension FirebaseAPIClient {
    public func endpoint(for auth: FirebaseEndpoint.Auth) -> FirebaseEndpoint {
        guard let serviceAccount = serviceAccount else {
            fatalError("Service account not set")
        }
        return FirebaseEndpoint.auth(auth, projectID: serviceAccount.projectId)
    }
    
    public func endpoint(for messages: FirebaseEndpoint.Messages) -> FirebaseEndpoint {
        guard let serviceAccount = serviceAccount else {
            fatalError("Service account not set")
        }
        return FirebaseEndpoint.messages(messages, projectID: serviceAccount.projectId)
    }
}
