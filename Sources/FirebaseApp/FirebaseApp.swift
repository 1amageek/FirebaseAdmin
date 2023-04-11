//
//  FirebaseApp.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

/**
 The singleton instance of the Firebase app.

 Use this property to access the `FirebaseApp` instance throughout your app.
 */
public class FirebaseApp {

    /**
    A class that represents a Firebase app.

    The FirebaseApp class provides a static method for initializing the app with a service account, which is necessary for authenticating with Firebase services. A service account contains the credentials required to authenticate with the Firebase API.

    The FirebaseApp class also contains a property named serviceAccount, which holds the loaded ServiceAccount object for the Firebase app.
    */
    public static var app: FirebaseApp = FirebaseApp()

    /**
     Initializes the Firebase app with a service account loaded from a JSON file.

     - Parameter fileName: The name of the JSON file containing the service account credentials. Defaults to "ServiceAccount".

     This method attempts to load the service account from the specified JSON file and assign it to the `serviceAccount` property of the `FirebaseApp` instance. If the file cannot be found, this method throws a `FileNotFoundError`.
     */
    public static func initialize(fileName: String = "ServiceAccount") {
        do {
            app.serviceAccount = try loadServiceAccount(from: fileName)
        } catch {
            fatalError("Service Account is not found.")
        }
    }

    /**
     Initializes the Firebase app with a given service account.

     - Parameter serviceAccount: A `ServiceAccount` object containing the credentials required to authenticate with Firebase services.

     Use this method to initialize the `FirebaseApp` instance with a service account object that has already been loaded.
     */
    public static func initialize(serviceAccount: ServiceAccount) {
        app.serviceAccount = serviceAccount
    }

    /**
     The service account for the Firebase app.

     The service account contains the credentials required to authenticate with Firebase services.
     */
    public var serviceAccount: ServiceAccount!

    /**
     Loads a `ServiceAccount` object from a JSON file.

     - Parameter jsonFile: The name of the JSON file containing the service account credentials.
     - Throws: A `FileNotFoundError` if the specified file cannot be found, or a `JSONParsingError` if an error occurs while parsing the file.

     Use this method to load a `ServiceAccount` object from a JSON file. This method returns a `ServiceAccount` object if the file is successfully parsed and the data is successfully decoded, or throws a `JSONParsingError` if an error occurs during parsing.
     */
    class func loadServiceAccount(from jsonFile: String) throws -> ServiceAccount {
        guard let path = Bundle.main.path(forResource: jsonFile, ofType: "json")  else {
            throw NSError(domain: "FileNotFoundError", code: 404, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"])
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let decoder = JSONDecoder()
            let serviceAccount = try decoder.decode(ServiceAccount.self, from: data)
            return serviceAccount
        } catch {
            throw NSError(domain: "JSONParsingError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error parsing JSON file: \(error)"])
        }
    }
}
