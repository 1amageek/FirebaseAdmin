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
}
