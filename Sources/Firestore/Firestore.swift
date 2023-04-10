import Foundation
import GRPC
import NIO
import SwiftProtobuf
import NIOHPACK
@_exported import FirebaseApp

public class Firestore {

    public struct Scope: AccessScope {
        public var value: String { "https://www.googleapis.com/auth/cloud-platform" }
    }

    var accessToken: String?

    var database: Database

    var app: FirebaseApp

    public static func firestore(app: FirebaseApp = FirebaseApp.app) -> Firestore {
        return Firestore(app: app)
    }

    init(app: FirebaseApp) {
        self.app = app
        self.database = Database(projectId: app.serviceAccount.projectId)
    }

    func getAccessToken() async throws -> String {
        if let accessToken { return accessToken }
        let accessTokenProvider = try AccessTokenProvider(serviceAccount: app.serviceAccount)
        let accessToken = try await accessTokenProvider.fetchAccessToken(Scope())
        self.accessToken = accessToken
        return accessToken
    }

    public func collection(_ collectionID: String) -> CollectionReference {
        if collectionID.isEmpty {
            fatalError("Collection ID cannot be empty.")
        }
        let components = collectionID
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        if components.count.isMultiple(of: 2) {
            fatalError("Invalid collection ID. \(collectionID).")
        }
        return CollectionReference(self, parentPath: nil, collectionID: collectionID)
    }

    public func document(_ documentID: String) -> DocumentReference {
        if documentID.isEmpty {
            fatalError("Document path cannot be empty.")
        }
        let components = documentID
            .split(separator: "/")
            .filter({ !$0.isEmpty })
        if !components.count.isMultiple(of: 2) {
            fatalError("Invalid path. \(documentID).")
        }
        let parentPath = components.dropLast(1).joined(separator: "/")
        let documentID = String(components.last!)
        return DocumentReference(self, parentPath: parentPath, documentID: documentID)
    }
}
