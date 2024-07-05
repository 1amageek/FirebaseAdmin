//
//  FirebaseAuth.swift
//
//
//  Created by Vamsi Madduluri on 04/07/24.
//

import Foundation
import AsyncHTTPClient
@_exported import FirebaseApp

/**
 A class that represents Firebase Authentication.
 
 The `Auth` class provides methods for accessing and managing user authentication within a Firebase project.
 */
public class FirebaseAuth {
    /**
     Returns an `AuthClient` instance initialized with the default `FirebaseApp` instance.
     
     - Parameter app: The `FirebaseApp` instance to use for authenticating with Firebase.
     
     Use this method to obtain an `AuthClient` instance that is initialized with the default `FirebaseApp` instance. This is useful if your app uses only one Firebase project and you need to access only one Firebase Authentication service.
     
     - Returns: An `AuthClient` instance initialized with the default `FirebaseApp` instance.
     */
    public static func auth(app: FirebaseApp = FirebaseApp.app) throws -> AuthClient {
        guard let serviceAccount = app.serviceAccount else {
            throw NSError(domain: "ServiceAccountError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Service Account is not initialized"])
        }
        let authClient = AuthClient(serviceAccount: serviceAccount)
        return authClient
    }
}
