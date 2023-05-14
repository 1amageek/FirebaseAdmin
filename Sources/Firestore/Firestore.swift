import Foundation
@_exported import FirestoreAPI
@_exported import FirebaseApp

/**
 A class that represents a Firestore database instance.
 
 The `Firestore` class provides methods for accessing collections and documents within a Firestore database.
 */
extension Firestore {

    /**
     A struct that represents an access scope for the Firestore database.

     The `Scope` struct conforms to the `AccessScope` protocol and provides a single read-only property that returns the URL for the access scope required for accessing the Firestore database.
     */
    struct Scope: FirestoreAPI.AccessScope {

        /// The URL for the access scope required for accessing the Firestore database.
        public var value: String { "https://www.googleapis.com/auth/cloud-platform" }
    }

    /**
     Returns a `Firestore` instance initialized with the default `FirebaseApp` instance.
     
     - Parameter app: The `FirebaseApp` instance to use for authenticating with the Firestore database.
     
     Use this method to obtain a `Firestore` instance that is initialized with the default `FirebaseApp` instance. This is useful if your app uses only one Firebase project and you need to access only one Firestore database.
     
     - Returns: A `Firestore` instance initialized with the default `FirebaseApp` instance.
     */
    public static func firestore(app: FirebaseApp = FirebaseApp.app) -> Firestore {
        let firestore = Firestore(projectId: app.serviceAccount.projectId)
        do {
            firestore.accessTokenProvider = try AccessTokenProvider(serviceAccount: app.serviceAccount)
            return firestore
        } catch {
            fatalError("Invalid Service Account.")
        }
    }

    /**
     Retrieves an access token for the Firestore database.

     Use this method to retrieve an access token for the Firestore database. If an access token has already been retrieved, this method returns it. Otherwise, it initializes an `AccessTokenProvider` instance with the `FirebaseApp` service account and retrieves a new access token using the `Scope` struct. The access token is then stored in the `accessToken` property of the `Firestore` instance and returned.

     - Returns: An access token for the Firestore database.
     - Throws: A `ServiceAccountError` if an error occurs while initializing the `AccessTokenProvider` instance or retrieving the access token.
     */
    func getAccessToken() async throws -> String? {
        return try await accessTokenProvider?.getAccessToken(expirationDuration: 3600)
    }
}
