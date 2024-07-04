//
//  FirebaseApp.swift
//
//
//  Created by Norikazu Muramoto on 2023/04/07.
//

import Foundation

public final class FirebaseApp: @unchecked Sendable {
    private static let _app = FirebaseApp()
    public static var app: FirebaseApp {
        get { _app }
    }
    
    private let lock = NSLock()
    private var _serviceAccount: ServiceAccount?
    
    private init() {}
    
    public var serviceAccount: ServiceAccount? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _serviceAccount
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _serviceAccount = newValue
        }
    }
    
    public static func initialize(fileName: String = "ServiceAccount") {
        do {
            let serviceAccount = try loadServiceAccount(from: fileName)
            initialize(serviceAccount: serviceAccount)
        } catch {
            fatalError("Service Account is not found.")
        }
    }
    
    public static func initialize(serviceAccount: ServiceAccount) {
        app.serviceAccount = serviceAccount
    }
    
    public static func loadServiceAccount(from jsonFile: String) throws -> ServiceAccount {
        guard let path = Bundle.main.path(forResource: jsonFile, ofType: "json") else {
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
    
    public func getServiceAccount() throws -> ServiceAccount {
        guard let serviceAccount = self.serviceAccount else {
            throw NSError(domain: "ServiceAccountError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Service Account is not initialized"])
        }
        return serviceAccount
    }
}
