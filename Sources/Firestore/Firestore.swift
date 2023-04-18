import Foundation
import GRPC
import NIO
import SwiftProtobuf
import NIOHPACK
@_exported import FirebaseApp

/**
 A class that represents a Firestore database instance.
 
 The `Firestore` class provides methods for accessing collections and documents within a Firestore database.
 */
public class Firestore {
    
    /**
     A struct that represents an access scope for the Firestore database.
     
     The `Scope` struct conforms to the `AccessScope` protocol and provides a single read-only property that returns the URL for the access scope required for accessing the Firestore database.
     */
    public struct Scope: AccessScope {
        
        /// The URL for the access scope required for accessing the Firestore database.
        public var value: String { "https://www.googleapis.com/auth/cloud-platform" }
    }
    
    /// The access token used for authentication with the Firestore database.
    var accessToken: String?
    
    /// The Firestore database instance.
    var database: Database
    
    /// The Firebase app instance used for authenticating with the Firestore database.
    var app: FirebaseApp
    
    /// The gRPC channel for communication with the Firestore API.
    var channel: ClientConnection
    
    /**
     Initializes a `Firestore` instance with a given `FirebaseApp` instance.
     
     - Parameter app: The `FirebaseApp` instance to use for authenticating with the Firestore database.
     
     Use this initializer to initialize a `Firestore` instance with a specific `FirebaseApp` instance. This is useful if your app uses multiple Firebase projects and you need to access different Firestore databases with different service accounts.
     */
    init(app: FirebaseApp) {
        self.app = app
        self.database = Database(projectId: app.serviceAccount.projectId)
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let timeout = TimeAmount.seconds(5)
        let channel = ClientConnection
            .usingTLSBackedByNIOSSL(on: group)
            .withConnectionTimeout(minimum: timeout)
            .connect(host: "firestore.googleapis.com", port: 443)
        self.channel = channel
    }
    
    /**
     Returns a `Firestore` instance initialized with the default `FirebaseApp` instance.
     
     - Parameter app: The `FirebaseApp` instance to use for authenticating with the Firestore database.
     
     Use this method to obtain a `Firestore` instance that is initialized with the default `FirebaseApp` instance. This is useful if your app uses only one Firebase project and you need to access only one Firestore database.
     
     - Returns: A `Firestore` instance initialized with the default `FirebaseApp` instance.
     */
    public static func firestore(app: FirebaseApp = FirebaseApp.app) -> Firestore {
        return Firestore(app: app)
    }
    
    /**
     Retrieves an access token for the Firestore database.
     
     Use this method to retrieve an access token for the Firestore database. If an access token has already been retrieved, this method returns it. Otherwise, it initializes an `AccessTokenProvider` instance with the `FirebaseApp` service account and retrieves a new access token using the `Scope` struct. The access token is then stored in the `accessToken` property of the `Firestore` instance and returned.
     
     - Returns: An access token for the Firestore database.
     - Throws: A `ServiceAccountError` if an error occurs while initializing the `AccessTokenProvider` instance or retrieving the access token.
     */
    func getAccessToken() async throws -> String {
        if let accessToken { return accessToken }
        let accessTokenProvider = try AccessTokenProvider(serviceAccount: app.serviceAccount)
        let accessToken = try await accessTokenProvider.fetchAccessToken(Scope())
        self.accessToken = accessToken
        return accessToken
    }
    
    /**
     Returns a CollectionGroup instance associated with the specified group ID.
     
     - Parameter groupID: A string value representing the group ID.
     - Returns: A `CollectionGroup` instance associated with the specified group ID.
     - Throws: A `FatalError` if the group ID is empty or contains a forward slash (/) character.
     */
    public func collectionGroup(_ groupID: String) -> CollectionGroup {
        if groupID.isEmpty {
            fatalError("Group ID cannot be empty.")
        }
        if groupID.contains("/") {
            fatalError("Invalid collection ID \(groupID). Collection IDs must not contain / in them.")
        }
        return CollectionGroup(database, groupID: groupID)
    }
    
    /**
     Returns a reference to a Firestore collection.
     
     - Parameter collectionID: The ID of the collection to reference.
     - Returns: A `CollectionReference` instance representing the specified Firestore collection.
     - Throws: A `FatalError` if the collection ID is empty or invalid.
     */
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
        return CollectionReference(database, parentPath: nil, collectionID: collectionID)
    }
    
    /**
     Returns a reference to a Firestore document.
     
     - Parameter documentID: The ID of the document to reference.
     - Returns: A `DocumentReference` instance representing the specified Firestore document.
     - Throws: A `FatalError` if the document ID is empty or the path is invalid.
     */
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
        return DocumentReference(database, parentPath: parentPath, documentID: documentID)
    }
}
