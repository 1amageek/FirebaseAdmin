//
//  FirebaseApp.swift
//  
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

public class FirebaseApp {

    public static var app: FirebaseApp = FirebaseApp()

    public static func initialize(fileName: String = "ServiceAccount") {
        do {
            app.serviceAccount = try loadServiceAccount(from: fileName)
        } catch {
            fatalError("Service Account is not found.")
        }
    }

    public static func initialize(serviceAccount: ServiceAccount) {
        app.serviceAccount = serviceAccount
    }

    public var serviceAccount: ServiceAccount!

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
