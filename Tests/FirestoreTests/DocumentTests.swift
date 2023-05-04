import XCTest
@testable import Firestore

final class DocumentTests: XCTestCase {

    override class func setUp() {
        let serviceAccount = try! loadServiceAccount(from: "ServiceAccount")
        FirebaseApp.initialize(serviceAccount: serviceAccount)
    }

    override func setUp() async throws {
        let collection = Firestore.firestore().collection("test")

        try await collection.document("doc")
            .setData([
                "number": 0,
                "string": "string",
                "bool": true,
                "array": ["0", "1"],
                "map": ["key": "value"],
                "date": Date(timeIntervalSince1970: 0),
                "timestamp": Timestamp(seconds: 0, nanos: 0),
                "data": "data".data(using: .utf8)!,
                "geoPoint": GeoPoint(latitude: 0, longitude: 0)
            ])

        try await collection.document("serverTimestamp")
            .setData([
                "serverTimestamp": FieldValue.serverTimestamp,
            ])
    }

    override func tearDown() async throws {
        let firestore = Firestore.firestore()
        let collection = firestore.collection("test")
        try await collection.document("doc").delete()
        try await collection.document("serverTimestamp").delete()
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

    func testEmptyDocument() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .document("empty")
            .getDocument()
        XCTAssertEqual(snapshot.isEmpty, true)
    }

    func testDocumentData() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .document("doc")
            .getDocument()
        let data = snapshot.data()!
        XCTAssertEqual(data["number"] as! Int, 0)
        XCTAssertEqual(data["string"] as! String, "string")
        XCTAssertEqual(data["bool"] as! Bool, true)
        XCTAssertEqual(data["array"] as! [String], ["0", "1"])
        XCTAssertEqual(data["map"] as! [String: String], ["key": "value"])
        XCTAssertEqual(data["date"] as! Timestamp, Timestamp(seconds: 0, nanos: 0))
        XCTAssertEqual(data["timestamp"] as! Timestamp, Timestamp(seconds: 0, nanos: 0))
        XCTAssertEqual(data["geoPoint"] as! GeoPoint, GeoPoint(latitude: 0, longitude: 0))
    }

    func testSeriverTimestamp() async throws {
        let snapshot = try await Firestore
            .firestore()
            .collection("test")
            .document("serverTimestamp")
            .getDocument()
        let data = snapshot.data()!
        XCTAssertTrue(data["serverTimestamp"] is Timestamp)
    }

    func testRoundtrip() async throws {
        struct DeepNestObject: Codable, Equatable {
            var number: Int = 0
            var string: String = "string"
            var bool: Bool = true
            var array: [String] = ["0", "1"]
            var map: [String: String] = ["value": "value"]
            var date: Date = Date(timeIntervalSince1970: 0)
            var timestamp: Timestamp = Timestamp(seconds: 0, nanos: 0)
            var geoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
            var reference: DocumentReference = Firestore.firestore().document("documents/id")
        }

        struct NestObject: Codable, Equatable {
            var number: Int = 0
            var string: String = "string"
            var bool: Bool = true
            var array: [String] = ["0", "1"]
            var map: [String: String] = ["value": "value"]
            var date: Date = Date(timeIntervalSince1970: 0)
            var timestamp: Timestamp = Timestamp(seconds: 0, nanos: 0)
            var geoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
            var reference: DocumentReference = Firestore.firestore().document("documents/id")
            var nested: DeepNestObject = DeepNestObject()
        }

        struct Object: Codable, Equatable {
            var number: Int = 0
            var string: String = "string"
            var bool: Bool = true
            var array: [String] = ["0", "1"]
            var map: [String: String] = ["value": "value"]
            var date: Date = Date(timeIntervalSince1970: 0)
            var timestamp: Timestamp = Timestamp(seconds: 0, nanos: 0)
            var geoPoint: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
            var reference: DocumentReference = Firestore.firestore().document("documents/id")
            var nested: NestObject = NestObject()
        }
        
        let writeData: Object = .init(
            number: 0,
            string: "string",
            bool: true,
            array: ["0", "1"],
            map: ["key": "value"],
            date: Date(timeIntervalSince1970: 0),
            timestamp: Timestamp(seconds: 0, nanos: 0),
            geoPoint: GeoPoint(latitude: 0, longitude: 0),
            reference: Firestore.firestore().document("documents/id"),
            nested: .init(
                number: 0,
                string: "string",
                bool: true,
                array: ["0", "1"],
                map: ["key": "value"],
                date: Date(timeIntervalSince1970: 0),
                timestamp: Timestamp(seconds: 0, nanos: 0),
                geoPoint: GeoPoint(latitude: 0, longitude: 0),
                reference: Firestore.firestore().document("documents/id"),
                nested: .init(
                    number: 0,
                    string: "string",
                    bool: true,
                    array: ["0", "1"],
                    map: ["key": "value"],
                    date: Date(timeIntervalSince1970: 0),
                    timestamp: Timestamp(seconds: 0, nanos: 0),
                    geoPoint: GeoPoint(latitude: 0, longitude: 0),
                    reference: Firestore.firestore().document("documents/id")
                )
            )
        )

        let ref = Firestore
            .firestore()
            .collection("test")
            .document("roundtrip")
                try await ref.setData(writeData)
        let readData = try await ref.getDocument(type: Object.self)

        XCTAssertEqual(writeData.number, readData!.number)
        XCTAssertEqual(writeData.string, readData!.string)
        XCTAssertEqual(writeData.bool, readData!.bool)
        XCTAssertEqual(writeData.array, readData!.array)
        XCTAssertEqual(writeData.map, readData!.map)
        XCTAssertEqual(writeData.date, readData!.date)
        XCTAssertEqual(writeData.timestamp, readData!.timestamp)
        XCTAssertEqual(writeData.geoPoint, readData!.geoPoint)
        XCTAssertEqual(writeData.reference, readData!.reference)
        XCTAssertEqual(writeData, readData)

    }
}
