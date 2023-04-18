import XCTest
@testable import Firestore

final class FirebaseEncoderTests: XCTestCase {

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

    struct NestData: Codable, Equatable {
        struct NestedData: Codable, Equatable {
            var number: Int = 0
            var string: String = "string"
        }
        var number: Int = 0
        var string: String = "string"
        var nested: NestedData = NestedData()
    }

    struct TestData: Codable, Equatable {
        var number: Int = 0
        var string: String = "string"
        var bool: Bool = true
        var array: [String] = ["0", "1"]
        var map: [String: String] = ["key": "value"]
        var date: Date = Date(timeIntervalSince1970: 0)
        var nested: NestData = NestData()
        var timestamp: Timestamp = Timestamp(seconds: 0, nanos: 0)
        var geoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
        var reference: DocumentReference = Firestore.firestore().document("test/0")
    }

    func testEncoder() async throws {
        let testData = TestData()
        let data = try! FirestoreEncoder().encode(testData)
        XCTAssertEqual(data["number"] as! Int, 0)
        XCTAssertEqual(data["string"] as! String, "string")
        XCTAssertEqual(data["bool"] as! Bool, true)
        XCTAssertEqual(data["array"] as! [String], ["0", "1"])
        XCTAssertEqual(data["map"] as! [String: String], ["key": "value"])
        XCTAssertEqual(data["date"] as! Date, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(data["timestamp"] as! Timestamp, Timestamp(seconds: 0, nanos: 0))
        XCTAssertEqual(data["geoPoint"] as! GeoPoint, GeoPoint(latitude: 0, longitude: 0))
        XCTAssertEqual(data["reference"] as! DocumentReference, Firestore.firestore().document("test/0"))
    }

    func testDecoder() async throws {
        let testData: [String: Any] = [
            "number": 0,
            "string": "string",
            "bool": true,
            "array": ["0", "1"],
            "map": ["key": "value"],
            "date": Date(timeIntervalSince1970: 0),
            "nested": ["number": 0, "string": "string", "nested": ["number": 0, "string": "string"]],
            "timestamp": Timestamp(seconds: 0, nanos: 0),
            "geoPoint": GeoPoint(latitude: 0, longitude: 0),
            "reference": Firestore.firestore().document("test/0")
        ]

        let data = try! FirestoreDecoder().decode(TestData.self, from: testData)

        print(data)

//
//        XCTAssertEqual(data["number"] as! Int, 0)
//        XCTAssertEqual(data["string"] as! String, "string")
//        XCTAssertEqual(data["bool"] as! Bool, true)
//        XCTAssertEqual(data["array"] as! [String], ["0", "1"])
//        XCTAssertEqual(data["map"] as! [String: String], ["key": "value"])
//        XCTAssertEqual(data["date"] as! Date, Date(timeIntervalSince1970: 0))
//        XCTAssertEqual(data["timestamp"] as! Timestamp, Timestamp(seconds: 0, nanos: 0))
//        XCTAssertEqual(data["geoPoint"] as! GeoPoint, GeoPoint(latitude: 0, longitude: 0))
//        XCTAssertEqual(data["reference"] as! DocumentReference, Firestore.firestore().document("test/0"))
    }
}
