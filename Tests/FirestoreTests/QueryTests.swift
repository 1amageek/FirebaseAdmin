import XCTest
@testable import Firestore

final class QueryTests: XCTestCase {

    override class func setUp() {
        let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
        FirebaseApp.initialize(serviceAccount: serviceAccount)
    }

//    override func setUp() async throws {
//        let collection = Firestore.firestore().collection("test")
//
//        // Prepare test data
//        for i in 1...39 {
//            try await collection.document("doc\(i)").setData(["number": i, "documentID": "doc\(i)"])
//        }
//    }

//    override func tearDown() async throws {
//        let firestore = Firestore.firestore()
//        let collection = firestore.collection("test")
//        let snapshot = try await collection.getDocuments()
//        for document in snapshot.documents {
//            try await document.documentReference.delete()
//        }
//    }

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

    func testGetQueryDocumentsWhereIsEqualTo() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .where(field: "number", isEqualTo: 1)
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 1)
        XCTAssertEqual(snapshot.documents.first?.data()["number"] as? Int, 1)
    }

    // Add more test cases for each QueryPredicate condition...
    func testGetQueryDocumentsWhereIsNotEqualTo() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .where(field: "number", isNotEqualTo: 1)
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 38)
    }

    // Continue adding test cases for all other field filter conditions...

    func testGetQueryDocumentsWhereIsEqualToDocumentID() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collectionGroup("test")
            .where(isEqualTo: "test/doc1")
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 1)
        XCTAssertEqual(snapshot.documents.first?.data()["number"] as? Int, 1)
    }

    func testGetQueryDocumentsWhereIsNotEqualToDocumentID() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collectionGroup("test")
            .where(isNotEqualTo: "test/doc1")
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 38)
    }

    // Continue adding test cases for all other DocumentID filter conditions...

    func testGetQueryDocumentsWithLimit() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .limit(to: 5)
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 5)
    }

    func testGetQueryDocumentsWithLimitToLast() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .limit(toLast: 5)
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 5)
    }

    func testGetQueryDocumentsWithLimitAndOrderBy() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .limit(to: 5)
            .order(by: "number", descending: false)
            .getDocuments()
        XCTAssertEqual(snapshot.documents.count, 5)
        XCTAssertEqual(snapshot.documents.first?.data()["number"] as? Int, 1)
    }
}
