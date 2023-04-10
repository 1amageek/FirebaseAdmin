import XCTest
@testable import Firestore

final class FirestoreTests: XCTestCase {

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

    func testPath() async throws {
        XCTAssertEqual(Firestore.firestore().collection("test").document("0").path, "test/0")
        XCTAssertEqual(Firestore.firestore().collection("test").document("0").path, "test/0")
        XCTAssertEqual(Firestore.firestore().collection("test").document("0/test/0").path, "test/0/test/0")
        XCTAssertEqual(Firestore.firestore().document("/test/0").path, "test/0")
        XCTAssertEqual(Firestore.firestore().document("/test/0").collection("test").path, "test/0/test")
        XCTAssertEqual(Firestore.firestore().document("/test/0").collection("test").document("0").path, "test/0/test/0")
        XCTAssertEqual(Firestore.firestore().document("/test/0").parent.path, "test")
        XCTAssertEqual(Firestore.firestore().document("/test/0").parent.path, "test")
    }

    func testGetDocument() async throws {
        let snapshot = try await Firestore
            .firestore()
            .document("/test/0")
            .getDocument()

        print(snapshot.data())
    }

    func testSetDocument() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .document("2")
            .setData(["number": 0, "string": "string"], merge: true)
        print(snapshot.data())
    }

    func testUpdateDocument() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .document("2")
            .updateData(["number": 1])
        print(snapshot.data())
    }

    func testUpdateAndDeleteDocument() async throws {
        let ref = Firestore
            .firestore()
            .collection("test")
            .document("4")
        let snapshot = try await ref.updateData(["number": 1])
        XCTAssertNotNil(snapshot.data())
        try await ref.delete()
    }

    func testGetListDocuments() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .getDocuments()
        print(snapshot.documents.count)
        print(snapshot.documents.map({ $0.data() }))
    }

    func testGetQueryDocuments() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .where(field: "number", isEqualTo: 1)
            .getDocuments()
        print(snapshot.documents.count)
        print(snapshot.documents.map({ $0.data() }))
    }
}
