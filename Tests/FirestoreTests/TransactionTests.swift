//
//  TransactionTests.swift
//  
//
//  Created by Norikazu Muramoto on 2023/05/13.
//

import XCTest
@testable import Firestore

final class TransactionTests: XCTestCase {

    override class func setUp() {
        let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
        FirebaseApp.initialize(serviceAccount: serviceAccount)
    }

    class func loadServiceAccount(from jsonFile: String) throws -> ServiceAccount {
        guard let path = Bundle.module.path(forResource: jsonFile, ofType: "json")  else {
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

    func testIncrement() async throws {
        let firestore = Firestore.firestore()
        let ref = firestore.collection("test").document("transaction")
        try await ref.delete()

        func increments() async {
            await withTaskGroup(of: Void.self) { group in
                for _ in (0..<10) {
                    group.addTask {
                        try! await firestore.runTransaction { transaction in
                            let snapshot = try await transaction.get(documentReference: ref)
                            if snapshot.exists {
                                let count = snapshot.data()!["count"] as! Int
                                transaction.set(documentReference: ref, data: ["count": count + 1])
                            } else {
                                transaction.create(documentReference: ref, data: ["count": 0])
                            }
                        }
                    }
                }
            }
        }

        await increments()
        let snapshot = try await ref.getDocument()
        let documentData = snapshot.data()!
        XCTAssertEqual(documentData["count"] as! Int, 9)
    }

    func testMultiIncrement() async throws {
        let firestore = Firestore.firestore()
        let ref0 = firestore.collection("test").document("transaction0")
        let ref1 = firestore.collection("test").document("transaction1")
        try await ref0.delete()
        try await ref1.delete()

        func increments() async {
            await withTaskGroup(of: Void.self) { group in
                for _ in (0..<10) {
                    group.addTask {
                        try! await firestore.runTransaction { transaction in
                            let snapshot0 = try await transaction.get(documentReference: ref0)
                            let snapshot1 = try await transaction.get(documentReference: ref1)
                            if snapshot0.exists {
                                let count = snapshot0.data()!["count"] as! Int
                                transaction.set(documentReference: ref0, data: ["count": count + 1])
                            } else {
                                transaction.create(documentReference: ref0, data: ["count": 0])
                            }
                            if snapshot1.exists {
                                let count = snapshot1.data()!["count"] as! Int
                                transaction.set(documentReference: ref1, data: ["count": count + 1])
                            } else {
                                transaction.create(documentReference: ref1, data: ["count": 0])
                            }
                        }
                    }
                }
            }
        }

        await increments()
        let snapshot0 = try await ref0.getDocument()
        let snapshot1 = try await ref1.getDocument()
        XCTAssertEqual(snapshot0.data()!["count"] as! Int, 9)
        XCTAssertEqual(snapshot1.data()!["count"] as! Int, 9)
    }
}
