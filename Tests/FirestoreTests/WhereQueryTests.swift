import XCTest
@testable import Firestore

final class WhereQueryTests: XCTestCase {

    override class func setUp() {
        let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
        FirebaseApp.initialize(serviceAccount: serviceAccount)
    }

    let path = "test/where/items"

    override func setUp() async throws {
        let ref = Firestore.firestore().collection(path)
        func isEven(_ number: Int) -> Bool {
            return number % 2 == 0
        }
        let batch = Firestore.firestore().batch()
        (1...10).forEach { index in
            batch.setData(data: [
                "index": index,
                "even": isEven(index)
            ], forDocument: ref.document("\(index)"))
        }
        try await batch.commit()
    }

    override func tearDown() async throws {
        let firestore = Firestore.firestore()
        let collection = firestore.collection(path)
        let snapshot = try await collection.getDocuments()
        for document in snapshot.documents {
            try await document.documentReference.delete()
        }
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

    func testWhereQueryIsEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "even", isEqualTo: true)
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 5)
            snapshot.documents.forEach { document in
                XCTAssertEqual(document.data()!["even"] as! Bool, true)
            }
        }
    }

    func testWhereQueryIsNotEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "even", isNotEqualTo: true)
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 5)
            snapshot.documents.forEach { document in
                XCTAssertEqual(document.data()!["even"] as! Bool, false)
            }
        }
    }

    func testWhereQueryIsLessThan() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "index", isLessThan: 5)
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 4)
            snapshot.documents.forEach { document in
                XCTAssertTrue((document.data()!["index"] as! Int) < 5)
            }
        }
    }

    func testWhereQueryIsLessThanOrEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "index", isLessThanOrEqualTo: 5)
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 5)
            snapshot.documents.forEach { document in
                XCTAssertTrue((document.data()!["index"] as! Int) <= 5)
            }
        }
    }

    func testWhereQueryIsGreaterThan() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "index", isGreaterThan: 5)
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 5)
            snapshot.documents.forEach { document in
                XCTAssertTrue((document.data()!["index"] as! Int) > 5)
            }
        }
    }

    func testWhereQueryIsGreaterThanOrEqualTo() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "index", isGreaterThanOrEqualTo: 5)
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 6)
            snapshot.documents.forEach { document in
                XCTAssertTrue((document.data()!["index"] as! Int) >= 5)
            }
        }
    }

    func testWhereQueryIn() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "index", in: [1, 3, 5, 7, 9])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 5)
            snapshot.documents.forEach { document in
                XCTAssertEqual(document.data()!["even"] as! Bool, false)
            }
        }
    }

    func testWhereQueryNotIn() async throws {
        let ref = Firestore.firestore().collection(path)
        do {
            let snapshot = try await ref.getDocuments()
            XCTAssertEqual(snapshot.documents.count, 10)
        }
        do {
            let snapshot = try await ref
                .where(field: "index", notIn: [1, 3, 5, 7, 9])
                .getDocuments()
            XCTAssertEqual(snapshot.documents.count, 5)
            snapshot.documents.forEach { document in
                XCTAssertEqual(document.data()!["even"] as! Bool, true)
            }
        }
    }
}
