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

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreate() async throws {
        let data: [String: Int] = ["count": 0]
        let firestore = Firestore.firestore()
        let ref = firestore.collection("test").document("transaction")
        try await firestore.runTransaction { transaction in
            transaction.create(documentReference: ref, data: data)
        }
        let snapshot = try await ref.getDocument()
        let documentData = snapshot.data()!
        XCTAssertEqual(documentData["count"] as! Int, 0)
    }


}
